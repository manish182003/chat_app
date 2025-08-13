import 'dart:async';
import 'package:logger/logger.dart';
import 'package:qurinom_chat/utils/constants/api_constant.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'models/message.dart';

class SocketService {
  static final String baseUrl = ApiConstant.baseUrl;
  late IO.Socket? _socket;
  final Logger _logger = Logger();
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<String> _connectionController =
      StreamController<String>.broadcast();

  Stream<Message> get messageStream => _messageController.stream;
  Stream<String> get connectionStream => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String userId) {
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {'userId': userId},
    });

    _socket?.onConnect((_) {
      _logger.i('Socket connected');
      _connectionController.add('connected');
    });

    _socket?.onDisconnect((_) {
      _logger.i('Socket disconnected');
      _connectionController.add('disconnected');
    });

    _socket?.onConnectError((error) {
      _logger.e('Socket connection error: $error');
      _connectionController.add('error');
    });

    // Listen for incoming messages
    _socket?.on('newMessage', (data) {
      try {
        final message = Message.fromJson(data);
        _messageController.add(message);
      } catch (e) {
        _logger.e('Error parsing incoming message: $e');
      }
    });

    // Join user's room
    _socket?.emit('joinRoom', {'userId': userId});
  }

  void joinChat(String chatId) {
    if (_socket?.connected ?? false) {
      _socket?.emit('joinChat', {'chatId': chatId});
    }
  }

  void leaveChat(String chatId) {
    if (_socket?.connected ?? false) {
      _socket?.emit('leaveChat', {'chatId': chatId});
    }
  }

  void sendMessage(Message message) {
    if (_socket?.connected ?? false) {
      _socket?.emit('sendMessage', message.toJson());
    }
  }

  void disconnect() {
    if (_socket?.connected ?? false) {
      _socket?.disconnect();
    }
    _messageController.close();
    _connectionController.close();
  }

  void onMessageReceived(Function(Message) callback) {
    _messageController.stream.listen(callback);
  }

  void onConnectionChanged(Function(String) callback) {
    _connectionController.stream.listen(callback);
  }
}
