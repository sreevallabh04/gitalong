import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Centralized HTTP client for the GitAlong Python backend.
///
/// Every authenticated request sends the Supabase session JWT as
/// `Authorization: Bearer <token>`.  All methods throw on failure so
/// callers can implement their own fallback strategy.
@lazySingleton
class BackendApiClient {
  final SupabaseClient _supabase;

  BackendApiClient(this._supabase);

  String get _baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'https://gitalong-backend.onrender.com';

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, String> _headers(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

  String _requireAccessToken() {
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('No active Supabase session');
    return session.accessToken;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// `GET /api/v1/health` — no auth required.
  Future<bool> healthCheck() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/api/v1/health'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// `GET /api/v1/recommendations?limit=N`
  Future<List<UserEntity>> getRecommendations({int limit = 20}) async {
    final token = _requireAccessToken();
    final uri =
        Uri.parse('$_baseUrl/api/v1/recommendations?limit=$limit');

    final res = await http
        .get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception(
          'Backend /recommendations returned ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['recommendations'] as List<dynamic>;

    AppLogger.i(
      'Backend: ${list.length} recommendations (algorithm: ${data['algorithm']})',
    );

    return list
        .map((j) => UserModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  /// `GET /api/v1/users/me`
  Future<UserEntity> getMe() async {
    final token = _requireAccessToken();
    final res = await http
        .get(Uri.parse('$_baseUrl/api/v1/users/me'), headers: _headers(token))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception(
          'Backend /users/me returned ${res.statusCode}: ${res.body}');
    }

    return UserModel.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    ).toEntity();
  }

  /// `GET /api/v1/users/{userId}`
  Future<UserEntity> getUser(String userId) async {
    final token = _requireAccessToken();
    final res = await http
        .get(
          Uri.parse('$_baseUrl/api/v1/users/$userId'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception(
          'Backend /users/$userId returned ${res.statusCode}: ${res.body}');
    }

    return UserModel.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    ).toEntity();
  }

  /// `POST /api/v1/users/me/refresh-github`
  Future<Map<String, dynamic>> refreshGitHubStats() async {
    final token = _requireAccessToken();
    final res = await http
        .post(
          Uri.parse('$_baseUrl/api/v1/users/me/refresh-github'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception(
          'Backend /refresh-github returned ${res.statusCode}: ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// `POST /api/v1/notify-match` — tell backend a match was created so the other user gets a notification.
  /// Does not throw on 4xx/5xx so match creation in Supabase remains successful; logs and returns.
  Future<void> notifyNewMatch(
    String matchId,
    String notifyUserId,
    String matcherName,
  ) async {
    try {
      final token = _requireAccessToken();
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/notify-match'),
            headers: _headers(token),
            body: jsonEncode({
              'match_id': matchId,
              'notify_user_id': notifyUserId,
              'matcher_name': matcherName,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode >= 400) {
        AppLogger.w(
          'Backend notify-match returned ${res.statusCode}: ${res.body}',
        );
      }
    } catch (e, st) {
      AppLogger.w('Backend notifyNewMatch failed', e, st);
    }
  }

  // ── Swipes ──────────────────────────────────────────────────────────────────

  /// `POST /api/v1/swipes` — record swipe on backend (populates CF signal).
  /// Returns `{status, matched, match_id}`.
  Future<Map<String, dynamic>?> recordSwipe({
    required String swipedUserId,
    required String action,
  }) async {
    try {
      final token = _requireAccessToken();
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/swipes'),
            headers: _headers(token),
            body: jsonEncode({
              'swiped_user_id': swipedUserId,
              'action': action,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      AppLogger.w('Backend /swipes returned ${res.statusCode}: ${res.body}');
      return null;
    } catch (e, st) {
      AppLogger.w('Backend recordSwipe failed', e, st);
      return null;
    }
  }

  // ── Matches ─────────────────────────────────────────────────────────────────

  /// `GET /api/v1/matches`
  Future<List<Map<String, dynamic>>> getMatches({int limit = 50}) async {
    final token = _requireAccessToken();
    final res = await http
        .get(
          Uri.parse('$_baseUrl/api/v1/matches?limit=$limit'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Backend /matches returned ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['matches'] ?? []);
  }

  // ── Messages ────────────────────────────────────────────────────────────────

  /// `GET /api/v1/matches/{matchId}/messages`
  Future<List<Map<String, dynamic>>> getMessages({
    required String matchId,
    int limit = 50,
  }) async {
    final token = _requireAccessToken();
    final res = await http
        .get(
          Uri.parse('$_baseUrl/api/v1/matches/$matchId/messages?limit=$limit'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Backend /messages returned ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['messages'] ?? []);
  }

  /// `POST /api/v1/matches/{matchId}/messages`
  Future<Map<String, dynamic>?> sendMessage({
    required String matchId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final token = _requireAccessToken();
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/matches/$matchId/messages'),
            headers: _headers(token),
            body: jsonEncode({
              'receiver_id': receiverId,
              'content': content,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['message'] as Map<String, dynamic>?;
      }
      AppLogger.w('Backend sendMessage returned ${res.statusCode}: ${res.body}');
      return null;
    } catch (e, st) {
      AppLogger.w('Backend sendMessage failed', e, st);
      return null;
    }
  }

  /// `PUT /api/v1/matches/{matchId}/messages/read`
  Future<void> markMessagesRead(String matchId) async {
    try {
      final token = _requireAccessToken();
      await http
          .put(
            Uri.parse('$_baseUrl/api/v1/matches/$matchId/messages/read'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 5));
    } catch (e, st) {
      AppLogger.w('Backend markMessagesRead failed', e, st);
    }
  }

  // ── Account ─────────────────────────────────────────────────────────────────

  /// `DELETE /api/v1/users/me` — full server-side account deletion.
  Future<bool> deleteAccount() async {
    try {
      final token = _requireAccessToken();
      final res = await http
          .delete(
            Uri.parse('$_baseUrl/api/v1/users/me'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 30));

      return res.statusCode == 200;
    } catch (e, st) {
      AppLogger.e('Backend deleteAccount failed', e, st);
      return false;
    }
  }
}
