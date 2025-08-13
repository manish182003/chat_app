part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

final class LoadChats extends ChatEvent {
  final String userId;

  LoadChats({required this.userId});
}

final class LoadChatMessages extends ChatEvent {
  final String chatId;

  LoadChatMessages({required this.chatId});
}

final class SendMessage extends ChatEvent {
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final String? fileUrl;

  SendMessage({
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl,
  });
}

final class MessageReceived extends ChatEvent {
  final Message message;

  MessageReceived({required this.message});
}

final class JoinChat extends ChatEvent {
  final String chatId;

  JoinChat({required this.chatId});
}

final class LeaveChat extends ChatEvent {
  final String chatId;

  LeaveChat({required this.chatId});
}
