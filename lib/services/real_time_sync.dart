import 'dart:async';
import 'package:flutter/material.dart';
import 'package:truklynk/services/sockerService.dart';

class RealTimeSyncExample extends StatefulWidget {
  @override
  _RealTimeSyncExampleState createState() => _RealTimeSyncExampleState();
}

class _RealTimeSyncExampleState extends State<RealTimeSyncExample> {
  final SocketService _socketService = SocketService();
  final List<FileUpload> _uploadedFiles = [];
  final StreamController<List<FileUpload>> _filesStreamController =
      StreamController<List<FileUpload>>.broadcast();

  bool _isConnecting = false;
  bool _isConnected = false;
  String _statusMessage = 'Not connected';

  @override
  void initState() {
    super.initState();
    _initializeSocketService();
  }

  Future<void> _initializeSocketService() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting...';
    });

    try {
      // Set up data change handler
      _socketService.onDataChange = _handleDataChange;

      // Initialize connections
      bool connected = await _socketService.initialize();

      setState(() {
        _isConnecting = false;
        _isConnected = connected;
        _statusMessage = connected ? 'Connected' : 'Connection failed';
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _isConnected = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _handleDataChange(dynamic data) {
    print('Received data change: $data');

    // Check if this is a new file notification
    if (data is Map && data['type'] == 'newFile' && data['data'] != null) {
      final fileData = data['data'];
      final newFile = FileUpload.fromJson(fileData);

      setState(() {
        _uploadedFiles.add(newFile);
      });

      _filesStreamController.add(_uploadedFiles);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New file received from another client')),
      );
    }
  }

  Future<void> _sendDataChange() async {
    try {
      // Example of sending a data change
      await _socketService.sendDataChange({
        'type': 'update',
        'entity': 'user',
        'id': 'user123',
        'changes': {'name': 'Updated Name', 'status': 'active'}
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data change sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending data change: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Sync Example'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: _isConnecting ? null : _initializeSocketService,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FileUpload>>(
              stream: _filesStreamController.stream,
              initialData: _uploadedFiles,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final files = snapshot.data ?? [];

                if (files.isEmpty) {
                  return Center(child: Text('No files uploaded yet'));
                }

                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return ListTile(
                      leading: file.mediaType?.startsWith('image') ?? false
                          ? Image.network(
                              file.mediaUrl ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, size: 50),
                            )
                          : Icon(Icons.insert_drive_file, size: 50),
                      title: Text(file.azureId ?? 'Unknown file'),
                      subtitle: Text(
                          '${file.contentType} - ${(file.mediaSize ?? 0) / 1024} KB'),
                      trailing: IconButton(
                        icon: Icon(Icons.open_in_new),
                        onPressed: () {
                          if (file.mediaUrl != null) {
                            // Open the file URL
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.sync),
                label: Text('Send Change'),
                onPressed: _isConnected ? _sendDataChange : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.dispose();
    _filesStreamController.close();
    super.dispose();
  }
}
