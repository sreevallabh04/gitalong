import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../services/backend_api_client.dart';
import '../../core/utils/logger.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;
  final BackendApiClient _backend;

  UserRepositoryImpl(this._supabase, this._backend);

  // ── Profile reads: backend-first, Supabase fallback ──────────────────────

  @override
  Future<UserEntity> getUserById(String userId) async {
    try {
      return await _backend.getUser(userId);
    } catch (e) {
      AppLogger.w('Backend getUser($userId) failed ($e), falling back to Supabase');
      return await _getUserByIdFromSupabase(userId);
    }
  }

  @override
  Future<UserEntity> getUserByUsername(String username) async {
    try {
      final doc = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .limit(1)
          .maybeSingle();

      if (doc == null) throw Exception('User not found');
      return UserModel.fromJson(doc).toEntity();
    } catch (e, st) {
      AppLogger.e('Error getting user by username', e, st);
      rethrow;
    }
  }

  @override
  Future<UserEntity> getCurrentUserProfile() async {
    try {
      return await _backend.getMe();
    } catch (e) {
      AppLogger.w('Backend getMe() failed ($e), falling back to Supabase');
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');
      return await _getUserByIdFromSupabase(currentUser.id);
    }
  }

  // ── Profile writes (Supabase-direct, no backend endpoint) ────────────────

  @override
  Future<UserEntity> updateUserProfile(UserEntity user) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final userModel = UserModel.fromEntity(user);
      final doc = await _supabase
          .from('users')
          .update(userModel.toJson())
          .eq('id', currentUser.id)
          .select()
          .single();

      return UserModel.fromJson(doc).toEntity();
    } catch (e, st) {
      AppLogger.e('Error updating user profile', e, st);
      rethrow;
    }
  }

  // ── Recommendations: backend ML engine, Supabase fallback ────────────────

  @override
  Future<List<UserEntity>> getRecommendedUsers({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      AppLogger.i('Fetching ML recommendations from backend');
      return await _backend.getRecommendations(limit: limit);
    } catch (e) {
      AppLogger.w('Backend recommendations failed ($e), falling back to Supabase');
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');
      return await _fallbackRecommendations(currentUser.id, limit);
    }
  }

  // ── GitHub stats refresh via backend ─────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getUserGitHubStats(String username) async {
    try {
      AppLogger.i('Refreshing GitHub stats via backend');
      return await _backend.refreshGitHubStats();
    } catch (e, st) {
      AppLogger.e('Backend refresh-github failed', e, st);
      rethrow;
    }
  }

  // ── Search (Supabase-direct, no backend endpoint) ────────────────────────

  @override
  Future<List<UserEntity>> searchUsers({
    required String query,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final docs = await _supabase
          .from('users')
          .select()
          .gte('username', query)
          .lt('username', '${query}z')
          .limit(limit);

      return docs
          .map((doc) => UserModel.fromJson(doc).toEntity())
          .toList();
    } catch (e, st) {
      AppLogger.e('Error searching users', e, st);
      rethrow;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<UserEntity> _getUserByIdFromSupabase(String userId) async {
    final doc =
        await _supabase.from('users').select().eq('id', userId).maybeSingle();
    if (doc == null) throw Exception('User not found');
    return UserModel.fromJson(doc).toEntity();
  }

  Future<List<UserEntity>> _fallbackRecommendations(
    String userId,
    int limit,
  ) async {
    final swiped = await _supabase
        .from('swipes')
        .select('swiped_user_id')
        .eq('swiper_id', userId);

    final swipedIds =
        (swiped as List).map((r) => r['swiped_user_id'] as String).toList();

    final excludeIds = [...swipedIds, userId];

    final data = await _supabase
        .from('users')
        .select()
        .not('id', 'in', excludeIds.isEmpty ? ['_dummy_'] : excludeIds)
        .order('last_active_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((row) => UserModel.fromJson(row as Map<String, dynamic>).toEntity())
        .toList();
  }
}
