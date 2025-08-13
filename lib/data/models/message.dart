class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType; // 'text', 'image', 'file'
  final String? fileUrl;
  final DateTime sentAt;
  final String status; // 'seen', 'delivered', 'sent'
  final DateTime? deliveredAt;
  final DateTime? seenAt;
  final List<String> seenBy;
  final List<String> deletedBy;
  final List<Map<String, dynamic>> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl,
    required this.sentAt,
    required this.status,
    this.deliveredAt,
    this.seenAt,
    required this.seenBy,
    required this.deletedBy,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      fileUrl: json['fileUrl'],
      sentAt:
          json['sentAt'] != null
              ? DateTime.parse(json['sentAt'])
              : DateTime.now(),
      status: json['status'] ?? 'sent',
      deliveredAt:
          json['deliveredAt'] != null
              ? DateTime.parse(json['deliveredAt'])
              : null,
      seenAt: json['seenAt'] != null ? DateTime.parse(json['seenAt']) : null,
      seenBy: json['seenBy'] != null ? List<String>.from(json['seenBy']) : [],
      deletedBy:
          json['deletedBy'] != null ? List<String>.from(json['deletedBy']) : [],
      reactions:
          json['reactions'] != null
              ? List<Map<String, dynamic>>.from(json['reactions'])
              : [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'messageType': messageType,
      'fileUrl': fileUrl,
      'sentAt': sentAt.toIso8601String(),
      'status': status,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'seenAt': seenAt?.toIso8601String(),
      'seenBy': seenBy,
      'deletedBy': deletedBy,
      'reactions': reactions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getter for backward compatibility
  DateTime get timestamp => sentAt;

  // Helper getter to check if message is read
  bool get isRead => seenBy.isNotEmpty;

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    String? messageType,
    String? fileUrl,
    DateTime? sentAt,
    String? status,
    DateTime? deliveredAt,
    DateTime? seenAt,
    List<String>? seenBy,
    List<String>? deletedBy,
    List<Map<String, dynamic>>? reactions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      seenAt: seenAt ?? this.seenAt,
      seenBy: seenBy ?? this.seenBy,
      deletedBy: deletedBy ?? this.deletedBy,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
