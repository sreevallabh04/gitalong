import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Calls the Python recommendation backend.
/// Falls back to a simple Supabase query if the backend is unavailable.
@lazySingleton
class RecommendationService {
  final SupabaseClient _supabase;

  RecommendationService(this._supabase);

  String get _backendUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:8000';

  // ── Public API ───────────────────────────────────────────────────────────

  Future<List<UserEntity>> getRecommendations({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('No user signed in');

    try {
      return await _fetchFromBackend(currentUser, limit);
    } catch (e) {
      AppLogger.w('Python backend unavailable ($e), falling back to Supabase');
      return await _fallbackFromSupabase(currentUser.id, limit);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<List<UserEntity>> _fetchFromBackend(
    User currentUser,
    int limit,
  ) async {
    // Retrieve the Supabase session JWT to authenticate with the backend
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('No active session');

    final uri = Uri.parse('$_backendUrl/api/v1/recommendations?limit=$limit');

    final response = await http
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Backend returned ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final recommendations = data['recommendations'] as List<dynamic>;

    AppLogger.i(
      'Python backend: ${recommendations.length} recommendations '
      '(algorithm: ${data['algorithm']})',
    );

    return recommendations.map((json) {
      return UserModel.fromJson(json as Map<String, dynamic>).toEntity();
    }).toList();
  }

  /// Simple fallback: fetch recent users excluding already-swiped
  Future<List<UserEntity>> _fallbackFromSupabase(
    String userId,
    int limit,
  ) async {
    final swiped = await _supabase
        .from('swipes')
        .select('swiped_user_id')
        .eq('swiper_id', userId);

    final swipedIds = (swiped as List)
        .map((r) => r['swiped_user_id'] as String)
        .toList();

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
