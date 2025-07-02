import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../config/firebase_config.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import '../core/utils/firestore_utils.dart';

abstract class IMessagingService {
  Future<MessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  });

  Future<List<MessageModel>> getMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  });

  Future<List<Map<String, dynamic>>> getConversations(String userId);
  Future<void> markMessagesAsRead({
    required String senderId,
    required String receiverId,
  });
  Future<int> getUnreadMessageCount(String userId);
  Stream<List<MessageModel>> listenToMessages({
    required String userId1,
    required String userId2,
  });
  Stream<List<MessageModel>> listenToNewMessages(String userId);
  Future<void> deleteMessage(String messageId);
  Future<List<MessageModel>> searchMessages({
    required String userId,
    required String query,
    int limit = 20,
  });
}

class MessagingService implements IMessagingService {
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  final Uuid _uuid = const Uuid();

  static const String _messagesCollection = 'messages';
  static const String _conversationsCollection = 'conversations';

  @override
  Future<MessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final messageId = _uuid.v4();
      final timestamp = DateTime.now();

      final messageData = {
        'id': messageId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'timestamp': Timestamp.fromDate(timestamp),
        'type': type.name,
        'is_read': false,
      };

      await safeQuery(() async {
        await _firestore
            .collection(_messagesCollection)
            .doc(messageId)
            .set(messageData);
      });

      // Update conversation metadata
      await _updateConversationMetadata(
          senderId, receiverId, content, timestamp);

      return MessageModel.fromJson({
        ...messageData,
        'timestamp': timestamp.toIso8601String(),
      });
    } catch (e) {
      AppLogger.logger.e('Failed to send message', error: e);
      throw MessagingException('Failed to send message: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await safeQuery(() async {
        return await _firestore
            .collection(_messagesCollection)
            .where(Filter.or(
              Filter.and(
                Filter('sender_id', isEqualTo: userId1),
                Filter('receiver_id', isEqualTo: userId2),
              ),
              Filter.and(
                Filter('sender_id', isEqualTo: userId2),
                Filter('receiver_id', isEqualTo: userId1),
              ),
            ))
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .get();
      });

      return querySnapshot.docs
          .map(
              (doc) => MessageModel.fromJson(_convertFirestoreData(doc.data())))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      AppLogger.logger.e('Failed to fetch messages', error: e);
      throw MessagingException('Failed to fetch messages: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final querySnapshot = await safeQuery(() async {
        return await _firestore
            .collection(_conversationsCollection)
            .where('participants', arrayContains: userId)
            .orderBy('last_message_timestamp', descending: true)
            .get();
      });

      return querySnapshot.docs
          .map((doc) => _convertFirestoreData(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.logger.e('Failed to fetch conversations', error: e);
      throw MessagingException('Failed to fetch conversations: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final batch = _firestore.batch();

      final querySnapshot = await safeQuery(() async {
        return await _firestore
            .collection(_messagesCollection)
            .where('sender_id', isEqualTo: senderId)
            .where('receiver_id', isEqualTo: receiverId)
            .where('is_read', isEqualTo: false)
            .get();
      });

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'is_read': true});
      }

      await batch.commit();
    } catch (e) {
      AppLogger.logger.e('Failed to mark messages as read', error: e);
      throw MessagingException('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final querySnapshot = await safeQuery(() async {
        return await _firestore
            .collection(_messagesCollection)
            .where('receiver_id', isEqualTo: userId)
            .where('is_read', isEqualTo: false)
            .count()
            .get();
      });

      return querySnapshot.count ?? 0;
    } catch (e) {
      AppLogger.logger.e('Failed to get unread message count', error: e);
      return 0;
    }
  }

  @override
  Stream<List<MessageModel>> listenToMessages({
    required String userId1,
    required String userId2,
  }) {
    return safeQuery(() async {
      return _firestore
          .collection(_messagesCollection)
          .where(Filter.or(
            Filter.and(
              Filter('sender_id', isEqualTo: userId1),
              Filter('receiver_id', isEqualTo: userId2),
            ),
            Filter.and(
              Filter('sender_id', isEqualTo: userId2),
              Filter('receiver_id', isEqualTo: userId1),
            ),
          ))
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  MessageModel.fromJson(_convertFirestoreData(doc.data())))
              .toList());
    });
  }

  @override
  Stream<List<MessageModel>> listenToNewMessages(String userId) {
    return safeQuery(() async {
      return _firestore
          .collection(_messagesCollection)
          .where('receiver_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  MessageModel.fromJson(_convertFirestoreData(doc.data())))
              .toList());
    });
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await safeQuery(() async {
        await _firestore
            .collection(_messagesCollection)
            .doc(messageId)
            .delete();
      });
    } catch (e) {
      AppLogger.logger.e('Failed to delete message', error: e);
      throw MessagingException('Failed to delete message: $e');
    }
  }

  @override
  Future<List<MessageModel>> searchMessages({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that searches for exact matches
      // For production, consider using Algolia or similar service
      final querySnapshot = await safeQuery(() async {
        return await _firestore
            .collection(_messagesCollection)
            .where(Filter.or(
              Filter('sender_id', isEqualTo: userId),
              Filter('receiver_id', isEqualTo: userId),
            ))
            .orderBy('timestamp', descending: true)
            .limit(limit * 5) // Get more to filter locally
            .get();
      });

      final messages = querySnapshot.docs
          .map(
              (doc) => MessageModel.fromJson(_convertFirestoreData(doc.data())))
          .where((message) =>
              message.content.toLowerCase().contains(query.toLowerCase()))
          .take(limit)
          .toList();

      return messages;
    } catch (e) {
      AppLogger.logger.e('Failed to search messages', error: e);
      throw MessagingException('Failed to search messages: $e');
    }
  }

  Future<void> _updateConversationMetadata(
    String senderId,
    String receiverId,
    String lastMessage,
    DateTime timestamp,
  ) async {
    final conversationId = _generateConversationId(senderId, receiverId);

    await safeQuery(() async {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .set({
        'id': conversationId,
        'participants': [senderId, receiverId],
        'last_message': lastMessage,
        'last_message_timestamp': Timestamp.fromDate(timestamp),
        'last_sender_id': senderId,
      }, SetOptions(merge: true));
    });
  }

  String _generateConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
    final convertedData = Map<String, dynamic>.from(data);

    // Convert Firestore Timestamp to ISO string
    if (convertedData['timestamp'] is Timestamp) {
      convertedData['timestamp'] =
          (convertedData['timestamp'] as Timestamp).toDate().toIso8601String();
    }

    if (convertedData['last_message_timestamp'] is Timestamp) {
      convertedData['last_message_timestamp'] =
          (convertedData['last_message_timestamp'] as Timestamp)
              .toDate()
              .toIso8601String();
    }

    return convertedData;
  }
}

class MessagingException implements Exception {
  final String message;

  const MessagingException(this.message);

  @override
  String toString() => 'MessagingException: $message';
}
