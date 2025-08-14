import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:typed_data';

class FileUpload {
  String? mediaUrl;
  String? contentType;
  String? mediaType;
  String? thumbnailUrl;
  int? mediaSize;
  bool? isUploaded;
  String? azureId;
  String? documentType;
  int? mediaDetailSno; // Add this field

  FileUpload({
    this.mediaUrl,
    this.contentType,
    this.mediaType,
    this.thumbnailUrl,
    this.mediaSize,
    this.isUploaded,
    this.azureId,
    this.documentType,
    this.mediaDetailSno, // Add this field
  });

  factory FileUpload.fromJson(Map<String, dynamic> json) {
    return FileUpload(
      mediaUrl: json['mediaUrl'],
      contentType: json['contentType'],
      mediaType: json['mediaType'],
      thumbnailUrl: json['thumbnailUrl'],
      mediaSize: json['mediaSize'],
      isUploaded: json['isUploaded'],
      azureId: json['azureId'],
      documentType: json['documentType'],
      mediaDetailSno: json['mediaDetailSno'], // Add this field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaUrl': mediaUrl,
      'contentType': contentType,
      'mediaType': mediaType,
      'thumbnailUrl': thumbnailUrl,
      'mediaSize': mediaSize,
      'isUploaded': isUploaded,
      'azureId': azureId,
      'documentType': documentType,
      'mediaDetailSno': mediaDetailSno, // Add this field
    };
  }
}

class SocketService {
  WebSocketChannel? channel;
  final int maxRetries = 3;
  final int retryDelay = 2;

  Uri _buildWebSocketUri(String endpoint) {
    // String ip = AppConfig.HOST; // Replace with your server IP
    String port = '8086';
    return Uri.parse('ws://192.168.1.40:$port/$endpoint');
  }

  Future<bool> connect({int retryCount = 0}) async {
    try {
      final uri = _buildWebSocketUri('api/goodone/file_upload');
      print('Attempting to connect to WebSocket at ${uri.toString()} (Attempt ${retryCount + 1})');

      channel = IOWebSocketChannel.connect(
        uri.toString(),
        connectTimeout: Duration(seconds: 30),
      );

      // Wait for connection to be established
      await Future.delayed(Duration(seconds: 1));

      if (channel?.sink != null) {
        print('WebSocket connection established successfully');
        return true;
      }

      throw WebSocketException('Failed to establish connection');
    } catch (e) {
      print('Connection error: $e');
      return _handleRetry(retryCount);
    }
  }

  Future<bool> _handleRetry(int retryCount) async {
    if (retryCount < maxRetries) {
      print('Retrying in $retryDelay seconds... (${retryCount + 1}/$maxRetries)');
      await Future.delayed(Duration(seconds: retryDelay));
      return connect(retryCount: retryCount + 1);
    }
    print('Max retries reached. Connection failed.');
    return false;
  }

  Future<List<FileUpload>> send({
    required List<File> files,
    required Map<String, dynamic> additionalData,
  }) async {
    if (files.isEmpty) {
      throw Exception('No files provided for upload');
    }

    try {
      bool connectionStatus = await connect();
      if (!connectionStatus) {
        throw Exception('WebSocket connection failed after multiple attempts');
      }

      final completer = Completer<List<FileUpload>>();

      // Send additional data first
      print('Sending additional data: $additionalData');
      channel!.sink.add(json.encode(additionalData));

      // Send number of files
      print('Sending number of files: ${files.length}');
      channel!.sink.add(files.length.toString());

      // Process each file
      for (int i = 0; i < files.length; i++) {
        File file = files[i];
        print('Processing file ${i + 1}');

        // Read file as bytes and convert to Uint8List
        List<int> bytes = await file.readAsBytes();
        Uint8List arrayBuffer = Uint8List.fromList(bytes);

        // Send file data
        channel!.sink.add(arrayBuffer);
        print('File ${i + 1} sent successfully');
      }

      channel!.stream.listen(
            (data) {
          print('Received response from server: $data');
          try {
            if (data.startsWith('Error')) {
              throw Exception('Server error: $data');
            }

            List<dynamic> apiResponseList = json.decode(data);

            if (apiResponseList.isNotEmpty) {
              List<FileUpload> res = apiResponseList.map((item) => FileUpload.fromJson(item)).toList();
              completer.complete(res);
            } else {
              throw Exception('Empty response from server');
            }
          } catch (e) {
            print('Error processing server response: $e');
            completer.completeError(e);
          } finally {
            channel?.sink.close();
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          completer.completeError(error);
          channel?.sink.close();
        },
        onDone: () {
          print('WebSocket connection closed');
          if (!completer.isCompleted) {
            completer.completeError('WebSocket connection closed unexpectedly');
          }
        },
        cancelOnError: true,
      );

      return completer.future;
    } catch (e) {
      print('Error in send method: $e');
      channel?.sink.close();
      throw e;
    }
  }
}
