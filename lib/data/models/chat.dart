import 'package:logger/logger.dart';

import 'user.dart';

class Chat {
  final String id;
  final bool isGroupChat;
  final List<User> participants;
  final DateTime? lastMessageTime;
  final String? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Chat({
    required this.id,
    required this.isGroupChat,
    required this.participants,
    this.lastMessageTime,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    List<User> participants = [];
    if (json['participants'] != null) {
      try {
        participants =
            (json['participants'] as List).map((participant) {
              try {
                return User.fromJson(participant);
              } catch (e) {
                Logger().i('Error parsing participant: $e');
                Logger().i('Participant data: $participant');
                // Return a default user to prevent crash
                return User(
                  id: participant['_id']?.toString() ?? 'unknown',
                  email:
                      participant['email']?.toString() ?? 'unknown@email.com',
                  name: participant['name']?.toString() ?? 'Unknown User',
                  role: participant['role']?.toString() ?? 'unknown',
                  profileImage: participant['profileImage']?.toString(),
                  createdAt: DateTime.now(),
                );
              }
            }).toList();
      } catch (e) {
        Logger().i('Error parsing participants list: $e');
        Logger().i('Participants data: ${json['participants']}');
      }
    }

    return Chat(
      id: json['id'] ?? json['_id'] ?? '',
      isGroupChat: json['isGroupChat'] ?? false,
      participants: participants,
      lastMessageTime:
          json['lastMessageTime'] != null
              ? DateTime.parse(json['lastMessageTime'])
              : null,
      lastMessage:
          json['lastMessage'] != null
              ? (json['lastMessage'] is Map
                  ? json['lastMessage']['content']?.toString()
                  : json['lastMessage'].toString())
              : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isGroupChat': isGroupChat,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods to get other user info
  String get otherUserName {
    if (participants.isEmpty) return '';
    // For now, return the first participant's name
    // You might want to filter out the current user
    return participants.first.name;
  }

  String get otherUserRole {
    if (participants.isEmpty) return '';
    return participants.first.role;
  }

  // Get other user (excluding current user)
  User? getOtherUser(String currentUserId) {
    if (participants.isEmpty) return null;
    try {
      return participants.firstWhere((user) => user.id != currentUserId);
    } catch (e) {
      // If no other user found, return first participant
      return participants.first;
    }
  }

  // Get last message content safely
  String get lastMessageContent {
    if (lastMessage == null) return 'No message';

    // If lastMessage is already a string (content), return it
    if (lastMessage is String) {
      return lastMessage as String;
    }

    // If lastMessage is a Map, extract the content
    if (lastMessage is Map) {
      final messageMap = lastMessage as Map;
      return messageMap['content']?.toString() ?? 'No message';
    }

    return 'No message';
  }

  Chat copyWith({
    String? id,
    bool? isGroupChat,
    List<User>? participants,
    DateTime? lastMessageTime,
    String? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      participants: participants ?? this.participants,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
