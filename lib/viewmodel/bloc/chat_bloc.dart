import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../data/api_service.dart';
import '../../data/socket_service.dart';
import '../../data/models/chat.dart';
import '../../data/models/message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  // Store chats locally to maintain state
  List<Chat> _chats = [];
  List<Message>? _currentMessages;
  String? _currentChatId;

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<JoinChat>(_onJoinChat);
    on<LeaveChat>(_onLeaveChat);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      final chats = await _apiService.getUserChats(event.userId);
      _chats = chats;
      emit(
        ChatStateWithData(
          chats: chats,
          messages: _currentMessages,
          currentChatId: _currentChatId,
        ),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = await _apiService.getChatMessages(event.chatId);
      _currentMessages = messages;
      _currentChatId = event.chatId;

      // Emit state with both chats and messages
      emit(
        ChatStateWithData(
          chats: _chats,
          messages: messages,
          currentChatId: event.chatId,
        ),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Send via API
      final response = await _apiService.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        content: event.content,
        messageType: event.messageType,
        fileUrl: event.fileUrl,
      );

      // Create message object with the response data from API
      final message = Message(
        id: response['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: event.chatId,
        senderId: event.senderId,
        content: event.content,
        messageType: event.messageType,
        fileUrl: event.fileUrl,
        sentAt:
            response['sentAt'] != null
                ? DateTime.parse(response['sentAt'])
                : DateTime.now(),
        status: response['status'] ?? 'sent',
        deliveredAt:
            response['deliveredAt'] != null
                ? DateTime.parse(response['deliveredAt'])
                : null,
        seenAt:
            response['seenAt'] != null
                ? DateTime.parse(response['seenAt'])
                : null,
        seenBy:
            response['seenBy'] != null
                ? List<String>.from(response['seenBy'])
                : [],
        deletedBy:
            response['deletedBy'] != null
                ? List<String>.from(response['deletedBy'])
                : [],
        reactions:
            response['reactions'] != null
                ? List<Map<String, dynamic>>.from(response['reactions'])
                : [],
        createdAt:
            response['createdAt'] != null
                ? DateTime.parse(response['createdAt'])
                : DateTime.now(),
        updatedAt:
            response['updatedAt'] != null
                ? DateTime.parse(response['updatedAt'])
                : DateTime.now(),
      );

      // Send via socket for real-time
      _socketService.sendMessage(message);

      // Add to current messages if we're in the right chat
      Logger().i(
        'Current chat ID: $_currentChatId, Event chat ID: ${event.chatId}',
      );
      if (_currentChatId == event.chatId) {
        // Initialize messages list if it's null
        _currentMessages ??= [];
        Logger().i(
          'Adding message to current messages. Current count: ${_currentMessages!.length}',
        );

        final updatedMessages = [..._currentMessages!, message];
        _currentMessages = updatedMessages;

        // Emit updated state
        Logger().i(
          'Emitting ChatStateWithData with ${updatedMessages.length} messages for chat ${event.chatId}',
        );
        emit(
          ChatStateWithData(
            chats: _chats,
            messages: updatedMessages,
            currentChatId: event.chatId,
          ),
        );
      } else {
        Logger().e(
          'Chat ID mismatch: current=$_currentChatId, event=${event.chatId}',
        );
      }
    } catch (e) {
      // Don't emit error state here, just log it
      Logger().e('Error sending message: $e');
      // Optionally, you could emit a specific error state for message sending
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    if (_currentChatId == event.message.chatId) {
      // Initialize messages list if it's null
      _currentMessages ??= [];

      final updatedMessages = [..._currentMessages!, event.message];
      _currentMessages = updatedMessages;

      Logger().i(
        'Emitting ChatStateWithData from _onMessageReceived with ${updatedMessages.length} messages for chat $_currentChatId',
      );
      emit(
        ChatStateWithData(
          chats: _chats,
          messages: updatedMessages,
          currentChatId: _currentChatId,
        ),
      );
    }
  }

  void _onJoinChat(JoinChat event, Emitter<ChatState> emit) {
    _socketService.joinChat(event.chatId);
  }

  void _onLeaveChat(LeaveChat event, Emitter<ChatState> emit) {
    _socketService.leaveChat(event.chatId);
  }

  void connectSocket(String userId) {
    _socketService.connect(userId);
    _socketService.onMessageReceived((message) {
      add(MessageReceived(message: message));
    });
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }

  // Method to refresh current state (useful when returning to home screen)
  void refreshCurrentState() {
    if (_chats.isNotEmpty && _currentChatId != null) {
      // Reload messages for current chat
      add(LoadChatMessages(chatId: _currentChatId!));
    }
  }
}
