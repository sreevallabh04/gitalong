import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

class MessagingService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final Uuid _uuid = const Uuid();

  // Send a message
  Future<MessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final messageData = {
        'id': _uuid.v4(),
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'type': type.name,
        'is_read': false,
      };

      final response =
          await _supabase
              .from('messages')
              .insert(messageData)
              .select()
              .single();

      return MessageModel.fromJson(response);
    } catch (e) {
      throw MessagingException('Failed to send message: $e');
    }
  }

  // Get messages between two users
  Future<List<MessageModel>> getMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .or(
            'and(sender_id.eq.$userId1,receiver_id.eq.$userId2),and(sender_id.eq.$userId2,receiver_id.eq.$userId1)',
          )
          .order('timestamp', ascending: false)
          .limit(limit);

      return response
          .map<MessageModel>((json) => MessageModel.fromJson(json))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw MessagingException('Failed to fetch messages: $e');
    }
  }

  // Get conversation list for a user
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      // Get latest message for each conversation
      final response = await _supabase.rpc(
        'get_user_conversations',
        params: {'user_id': userId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw MessagingException('Failed to fetch conversations: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId)
          .eq('is_read', false);
    } catch (e) {
      throw MessagingException('Failed to mark messages as read: $e');
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // Listen to real-time messages
  Stream<List<MessageModel>> listenToMessages({
    required String userId1,
    required String userId2,
  }) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .map(
          (data) => data.map((item) => MessageModel.fromJson(item)).toList(),
        );
  }

  // Listen to new conversations
  Stream<List<MessageModel>> listenToNewMessages(String userId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .map(
          (data) => data.map((item) => MessageModel.fromJson(item)).toList(),
        );
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
    } catch (e) {
      throw MessagingException('Failed to delete message: $e');
    }
  }

  // Search messages
  Future<List<MessageModel>> searchMessages({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .textSearch('content', query)
          .order('timestamp', ascending: false)
          .limit(limit);

      return response
          .map<MessageModel>((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      throw MessagingException('Failed to search messages: $e');
    }
  }
}

class MessagingException implements Exception {
  final String message;

  const MessagingException(this.message);

  @override
  String toString() => 'MessagingException: $message';
}
