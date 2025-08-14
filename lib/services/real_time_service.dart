import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A service for handling real-time data synchronization via WebSockets
class RealTimeService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>> _dataStreamController = StreamController.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final int maxRetries = 5;
  final int retryDelay = 3;
  int _retryCount = 0;

  // Configuration
  final String _host;
  final String _port;
  final String _endpoint;
  final Map<String, dynamic> _authData;

  // Stream that clients can listen to for real-time updates
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  // Connection status
  bool get isConnected => _isConnected;

  RealTimeService({
    required String host,
    required String port,
    required String endpoint,
    required Map<String, dynamic> authData,
  }) : _host = host,
        _port = port,
        _endpoint = endpoint,
        _authData = authData;

  /// Initialize the WebSocket connection
  Future<bool> connect() async {
    if (_isConnected) {
      print('Already connected to WebSocket');
      return true;
    }

    try {
      final uri = Uri.parse('ws://$_host:$_port/$_endpoint');
      print('Connecting to WebSocket at $uri');

      _channel = IOWebSocketChannel.connect(
        uri.toString(),
        connectTimeout: Duration(seconds: 30),
      );

      // Wait briefly to ensure connection is established
      await Future.delayed(Duration(seconds: 1));

      // Send authentication data
      _channel!.sink.add(json.encode(_authData));

      // Set up stream listener
      _setupStreamListener();

      // Start heartbeat to keep connection alive
      _startHeartbeat();

      _isConnected = true;
      _retryCount = 0;
      print('WebSocket connection established successfully');
      return true;
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
      return _handleReconnect();
    }
  }

  /// Set up the listener for incoming WebSocket messages
  void _setupStreamListener() {
    _channel!.stream.listen(
          (dynamic data) {
        try {
          // Handle different types of data
          if (data is String) {
            final decodedData = json.decode(data);

            // Check if it's a heartbeat response
            if (decodedData is Map && decodedData['type'] == 'heartbeat') {
              print('Heartbeat response received');
              return;
            }

            // Forward the data to listeners
            _dataStreamController.add(decodedData);
          }
        } catch (e) {
          print('Error processing WebSocket data: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _isConnected = false;
        _handleReconnect();
      },
      onDone: () {
        print('WebSocket connection closed');
        _isConnected = false;
        _handleReconnect();
      },
      cancelOnError: false,
    );
  }

  /// Handle reconnection logic
  Future<bool> _handleReconnect() async {
    // Cancel any existing timers
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    if (_retryCount < maxRetries) {
      _retryCount++;
      print('Attempting to reconnect in $retryDelay seconds (Attempt $_retryCount/$maxRetries)');

      _reconnectTimer = Timer(Duration(seconds: retryDelay), () async {
        await connect();
      });
      return false;
    } else {
      print('Max reconnection attempts reached');
      // Notify listeners about connection failure
      _dataStreamController.add({'type': 'connection_error', 'message': 'Failed to connect after $maxRetries attempts'});
      return false;
    }
  }

  /// Send a heartbeat to keep the connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          _channel!.sink.add(json.encode({'type': 'heartbeat'}));
        } catch (e) {
          print('Error sending heartbeat: $e');
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Send data to the WebSocket server
  Future<bool> sendData(Map<String, dynamic> data) async {
    if (!_isConnected) {
      print('Cannot send data: WebSocket not connected');
      await connect();
      if (!_isConnected) return false;
    }

    try {
      _channel!.sink.add(json.encode(data));
      return true;
    } catch (e) {
      print('Error sending data: $e');
      return false;
    }
  }

  /// Subscribe to specific data updates
  Future<bool> subscribe(String topic, {Map<String, dynamic>? params}) async {
    return sendData({
      'type': 'subscribe',
      'topic': topic,
      'params': params ?? {},
    });
  }

  /// Unsubscribe from specific data updates
  Future<bool> unsubscribe(String topic) async {
    return sendData({
      'type': 'unsubscribe',
      'topic': topic,
    });
  }

  /// Close the WebSocket connection
  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }

    _isConnected = false;
    print('WebSocket connection closed');
  }

  /// Dispose of resources
  void dispose() {
    disconnect();
    _dataStreamController.close();
  }
}
