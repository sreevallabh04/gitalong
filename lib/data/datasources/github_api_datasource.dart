import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';
import '../models/project_model.dart';

@injectable
class GitHubApiDataSource {
  final Dio _dio;

  GitHubApiDataSource(this._dio);

  /// Get user information from GitHub API
  Future<UserModel> getUser(String username) async {
    try {
      final response = await _dio.get('/users/$username');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Get authenticated user information
  Future<UserModel> getAuthenticatedUser() async {
    try {
      final response = await _dio.get('/user');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch authenticated user: $e');
    }
  }

  /// Get user repositories
  Future<List<ProjectModel>> getUserRepositories(String username) async {
    try {
      final response = await _dio.get('/users/$username/repos');
      final List<dynamic> repos = response.data;
      return repos.map((repo) => ProjectModel.fromJson(repo)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user repositories: $e');
    }
  }

  /// Get repository details
  Future<ProjectModel> getRepository(String owner, String repo) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo');
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch repository: $e');
    }
  }

  /// Search repositories
  Future<List<ProjectModel>> searchRepositories(String query) async {
    try {
      final response = await _dio.get(
        '/search/repositories',
        queryParameters: {
          'q': query,
          'sort': 'stars',
          'order': 'desc',
          'per_page': 30,
        },
      );
      final List<dynamic> repos = response.data['items'];
      return repos.map((repo) => ProjectModel.fromJson(repo)).toList();
    } catch (e) {
      throw Exception('Failed to search repositories: $e');
    }
  }

  /// Get trending repositories
  Future<List<ProjectModel>> getTrendingRepositories() async {
    try {
      final response = await _dio.get(
        '/search/repositories',
        queryParameters: {
          'q':
              'created:>${DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T')[0]}',
          'sort': 'stars',
          'order': 'desc',
          'per_page': 30,
        },
      );
      final List<dynamic> repos = response.data['items'];
      return repos.map((repo) => ProjectModel.fromJson(repo)).toList();
    } catch (e) {
      throw Exception('Failed to fetch trending repositories: $e');
    }
  }

  /// Get user's contribution graph
  Future<Map<String, dynamic>> getContributionGraph(String username) async {
    try {
      final response = await _dio.get('/users/$username/events');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch contribution graph: $e');
    }
  }

  /// Star a repository
  Future<void> starRepository(String owner, String repo) async {
    try {
      await _dio.put('/user/starred/$owner/$repo');
    } catch (e) {
      throw Exception('Failed to star repository: $e');
    }
  }

  /// Unstar a repository
  Future<void> unstarRepository(String owner, String repo) async {
    try {
      await _dio.delete('/user/starred/$owner/$repo');
    } catch (e) {
      throw Exception('Failed to unstar repository: $e');
    }
  }

  /// Check if repository is starred
  Future<bool> isRepositoryStarred(String owner, String repo) async {
    try {
      final response = await _dio.get('/user/starred/$owner/$repo');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
