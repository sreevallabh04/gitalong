import '../entities/message_entity.dart';

/// Chat repository interface
abstract class ChatRepository {
  /// Get messages for a match
  Future<List<MessageEntity>> getMessages({
    required String matchId,
    int limit = 50,
    String? cursor,
  });
  
  /// Send a message
  Future<MessageEntity> sendMessage({
    required String matchId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  });
  
  /// Mark message as read
  Future<void> markMessageAsRead(String messageId);
  
  /// Mark all messages in a chat as read
  Future<void> markAllMessagesAsRead(String matchId);
  
  /// Listen to new messages
  Stream<MessageEntity> listenToMessages(String matchId);
  
  /// Delete message
  Future<void> deleteMessage(String messageId);
}



