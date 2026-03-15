import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepositoryImpl(this._supabase);

  @override
  Stream<NewMatchNotification> listenToNewMatchNotifications(String userId) {
    final seenIds = <String>{};
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncExpand((data) async* {
          for (final row in data) {
            final id = row['id']?.toString();
            final type = row['type'] as String?;
            if (id == null || type != 'new_match') continue;
            if (seenIds.contains(id)) continue;
            seenIds.add(id);
            final payload = row['payload'] as Map<String, dynamic>?;
            if (payload == null) continue;
            final matchId = payload['match_id'] as String?;
            final fromUserName =
                payload['from_user_name'] as String? ?? 'Someone';
            if (matchId != null) {
              yield NewMatchNotification(
                matchId: matchId,
                fromUserName: fromUserName,
              );
            }
          }
        });
  }
}
