import '../entities/notification_entity.dart';

/// Streams in-app notifications for the current user (e.g. new_match).
abstract class NotificationRepository {
  /// Stream of new-match notifications. Only emits for rows not seen in this session.
  Stream<NewMatchNotification> listenToNewMatchNotifications(String userId);
}
