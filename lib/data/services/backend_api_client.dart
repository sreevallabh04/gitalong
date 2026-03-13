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
      dotenv.env['BACKEND_URL'] ?? 'https://gitalong-api.onrender.com';

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
}
