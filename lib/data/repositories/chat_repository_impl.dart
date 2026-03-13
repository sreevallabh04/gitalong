import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../core/utils/logger.dart';

/// Chat repository implementation
@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;

  ChatRepositoryImpl(this._supabase);

  @override
  Future<List<MessageEntity>> getMessages({
    required String matchId,
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final data = await _supabase
          .from('messages')
          .select()
          .eq('match_id', matchId)
          .order('sent_at', ascending: false)
          .limit(limit);

      return data.map((doc) {
        return MessageEntity(
          id: doc['id'].toString(),
          matchId: matchId,
          senderId: doc['sender_id'] as String,
          receiverId: doc['receiver_id'] as String,
          content: doc['content'] as String,
          type: MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == doc['type'],
            orElse: () => MessageType.text,
          ),
          sentAt: DateTime.parse(doc['sent_at'] as String),
          isRead: doc['is_read'] as bool? ?? false,
        );
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting messages', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<MessageEntity> sendMessage({
    required String matchId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final now = DateTime.now();
      final messageData = {
        'match_id': matchId,
        'sender_id': currentUser.id,
        'receiver_id': receiverId,
        'content': content,
        'type': type.toString().split('.').last,
        'sent_at': now.toIso8601String(),
        'is_read': false,
      };

      final row =
          await _supabase.from('messages').insert(messageData).select().single();

      // Update the match's last_message preview
      await _supabase.from('matches').update({
        'last_message': content,
        'last_message_at': now.toIso8601String(),
      }).eq('id', matchId);

      return MessageEntity(
        id: row['id'].toString(),
        matchId: matchId,
        senderId: currentUser.id,
        receiverId: receiverId,
        content: content,
        type: type,
        sentAt: DateTime.parse(row['sent_at'] as String),
        isRead: false,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error sending message', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('id', messageId);
    } catch (e, stackTrace) {
      AppLogger.e('Error marking message as read', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> markAllMessagesAsRead(String matchId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('match_id', matchId)
          .eq('receiver_id', currentUser.id)
          .eq('is_read', false);
    } catch (e, stackTrace) {
      AppLogger.e('Error marking all messages as read', e, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<MessageEntity> listenToMessages(String matchId) {
    try {
      final processedIds = <String>{};
      return _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('match_id', matchId)
          .order('sent_at', ascending: true)
          .asyncExpand((data) async* {
            for (final doc in data) {
              final id = doc['id'].toString();
              if (!processedIds.contains(id)) {
                processedIds.add(id);
                yield MessageEntity(
                  id: id,
                  matchId: matchId,
                  senderId: doc['sender_id'] as String,
                  receiverId: doc['receiver_id'] as String,
                  content: doc['content'] as String,
                  type: MessageType.values.firstWhere(
                    (e) => e.toString().split('.').last == doc['type'],
                    orElse: () => MessageType.text,
                  ),
                  sentAt: DateTime.parse(doc['sent_at'] as String),
                  isRead: doc['is_read'] as bool? ?? false,
                );
              }
            }
          });
    } catch (e, stackTrace) {
      AppLogger.e('Error listening to messages', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
    } catch (e, stackTrace) {
      AppLogger.e('Error deleting message', e, stackTrace);
      rethrow;
    }
  }
}
