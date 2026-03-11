import 'package:equatable/equatable.dart';

/// Message entity
class MessageEntity extends Equatable {
  final String id;
  final String matchId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    required this.sentAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
    id,
    matchId,
    senderId,
    receiverId,
    content,
    type,
    sentAt,
    isRead,
  ];

  /// Copy with method
  MessageEntity copyWith({
    String? id,
    String? matchId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Message type enum
enum MessageType { text, image, link, code }
