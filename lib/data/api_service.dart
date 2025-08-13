import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:qurinom_chat/utils/constants/api_constant.dart';

import 'models/chat.dart';
import 'models/message.dart';

class ApiService {
  static final String baseUrl = ApiConstant.baseUrl;
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('Response: ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            'Error: ${error.response?.statusCode} ${error.response?.data}',
          );
          return handler.next(error);
        },
      ),
    );

    // // Add interceptors for logging and error handling
    // _dio.interceptors.add(
    //   LogInterceptor(requestBody: true, responseBody: true, error: true),
    // );
  }

  // Login API
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/user/login',
        data: {'email': email, 'password': password, 'role': role},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  // Get user chats
  Future<List<Chat>> getUserChats(String userId) async {
    try {
      final response = await _dio.get('/chats/user-chats/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> chatsData = response.data;
        _logger.i('Raw chats data: $chatsData');

        List<Chat> chats = [];
        for (int i = 0; i < chatsData.length; i++) {
          try {
            _logger.i('Parsing chat $i: ${chatsData[i]}');
            final chat = Chat.fromJson(chatsData[i]);
            chats.add(chat);
          } catch (e) {
            _logger.e('Error parsing chat $i: $e');
            _logger.e('Chat data: ${chatsData[i]}');
          }
        }

        return chats;
      } else {
        throw Exception('Failed to fetch chats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch chats: ${e.message}');
    }
  }

  // Get chat messages
  Future<List<Message>> getChatMessages(String chatId) async {
    try {
      final response = await _dio.get(
        '/messages/get-messagesformobile/$chatId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data;
        _logger.i('Raw messages data: $messagesData');

        List<Message> messages = [];
        for (int i = 0; i < messagesData.length; i++) {
          try {
            _logger.i('Parsing message $i: ${messagesData[i]}');
            final message = Message.fromJson(messagesData[i]);
            messages.add(message);
          } catch (e) {
            _logger.e('Error parsing message $i: $e');
            _logger.e('Message data: ${messagesData[i]}');
          }
        }

        return messages;
      } else {
        throw Exception('Failed to fetch messages: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch messages: ${e.message}');
    }
  }

  // Send message
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    required String messageType,
    String? fileUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/messages/sendMessage',
        data: {
          'chatId': chatId,
          'senderId': senderId,
          'content': content,
          'messageType': messageType,
          'fileUrl': fileUrl ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to send message: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to send message: ${e.message}');
    }
  }
}
