import '../entities/chat_entity.dart';

/// Repository for chat-related operations
abstract class ChatRepository {
  /// Get all chats for current user
  Future<List<ChatEntity>> getChats({int limit = 20});

  /// Get chat by ID
  Future<ChatEntity?> getChatById(String chatId);

  /// Create a new chat
  Future<ChatEntity> createChat(ChatEntity chat);

  /// Update chat
  Future<ChatEntity> updateChat(ChatEntity chat);

  /// Delete chat
  Future<void> deleteChat(String chatId);

  /// Get messages for a chat
  Future<List<MessageEntity>> getMessages(String chatId, {int limit = 50});

  /// Send a message
  Future<MessageEntity> sendMessage(MessageEntity message);

  /// Update message
  Future<MessageEntity> updateMessage(MessageEntity message);

  /// Delete message
  Future<void> deleteMessage(String messageId);

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, List<String> messageIds);

  /// Get unread message count
  Future<int> getUnreadCount();

  /// Stream of new messages
  Stream<MessageEntity> getMessageStream(String chatId);

  /// Stream of chat updates
  Stream<ChatEntity> getChatUpdates(String chatId);

  /// Stream of typing indicators
  Stream<TypingIndicator> getTypingStream(String chatId);

  /// Send typing indicator
  Future<void> sendTypingIndicator(String chatId, {required bool isTyping});
}

/// Represents a typing indicator in a chat
class TypingIndicator {
  /// ID of the user who is typing
  final String userId;

  /// Username of the user who is typing
  final String username;

  /// Whether the user is currently typing
  final bool isTyping;

  /// Timestamp of the typing indicator
  final DateTime timestamp;

  /// Creates a typing indicator
  const TypingIndicator({
    required this.userId,
    required this.username,
    required this.isTyping,
    required this.timestamp,
  });
}
