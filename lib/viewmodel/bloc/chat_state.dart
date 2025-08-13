part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatsLoaded extends ChatState {
  final List<Chat> chats;

  ChatsLoaded({required this.chats});
}

final class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;
  final String chatId;

  ChatMessagesLoaded({required this.messages, required this.chatId});
}

final class ChatStateWithData extends ChatState {
  final List<Chat> chats;
  final List<Message>? messages;
  final String? currentChatId;

  ChatStateWithData({required this.chats, this.messages, this.currentChatId});
}

final class ChatError extends ChatState {
  final String message;

  ChatError({required this.message});
}
