import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// GitHub API integration service
@lazySingleton
class GitHubService {
  final Dio _dio;
  
  GitHubService(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.githubApiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
      },
    );
  }
  
  /// Fetch user repositories with detailed information
  Future<List<GitHubRepository>> getUserRepositories(String username) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.userReposList(username),
        queryParameters: {
          'sort': 'updated',
          'per_page': 100,
        },
      );
      
      if (response.statusCode == 200) {
        final repos = (response.data as List)
            .map((json) => GitHubRepository.fromJson(json))
            .toList();
        
        AppLogger.d('Fetched ${repos.length} repositories for $username');
        return repos;
      }
      
      return [];
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching repositories for $username', e, stackTrace);
      return [];
    }
  }
  
  /// Analyze programming languages used by developer
  Future<Map<String, int>> analyzeLanguages(String username) async {
    try {
      final repos = await getUserRepositories(username);
      final languageStats = <String, int>{};
      
      for (final repo in repos) {
        if (repo.language != null && repo.language!.isNotEmpty) {
          languageStats[repo.language!] = 
              (languageStats[repo.language!] ?? 0) + repo.stargazersCount + 1;
        }
      }
      
      // Sort by usage (weighted by stars)
      final sortedLanguages = Map.fromEntries(
        languageStats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );
      
      AppLogger.d('Analyzed languages for $username: ${sortedLanguages.keys.take(5).join(", ")}');
      return sortedLanguages;
    } catch (e, stackTrace) {
      AppLogger.e('Error analyzing languages for $username', e, stackTrace);
      return {};
    }
  }
  
  /// Calculate developer activity score
  Future<DeveloperScore> calculateDeveloperScore(String username) async {
    try {
      final repos = await getUserRepositories(username);
      
      int totalStars = 0;
      int totalForks = 0;
      int totalCommits = 0;
      int publicRepos = repos.length;
      Set<String> languages = {};
      Set<String> topics = {};
      
      for (final repo in repos) {
        totalStars += repo.stargazersCount;
        totalForks += repo.forksCount;
        languages.add(repo.language ?? 'Unknown');
        topics.addAll(repo.topics);
        
        // Estimate commits (size as proxy)
        totalCommits += (repo.size ~/ 10).clamp(0, 100);
      }
      
      // Calculate composite score
      final activityScore = _calculateActivityScore(
        stars: totalStars,
        forks: totalForks,
        repos: publicRepos,
        languages: languages.length,
      );
      
      final score = DeveloperScore(
        username: username,
        totalStars: totalStars,
        totalForks: totalForks,
        totalCommits: totalCommits,
        publicRepos: publicRepos,
        languageCount: languages.length,
        languages: languages.toList(),
        topics: topics.toList(),
        activityScore: activityScore,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.d('Developer score for $username: ${score.activityScore}/100');
      return score;
    } catch (e, stackTrace) {
      AppLogger.e('Error calculating score for $username', e, stackTrace);
      return DeveloperScore.empty(username);
    }
  }
  
  /// Calculate activity score (0-100)
  double _calculateActivityScore({
    required int stars,
    required int forks,
    required int repos,
    required int languages,
  }) {
    // Weighted scoring algorithm
    final starScore = (stars / 10).clamp(0, 40).toDouble();
    final forkScore = (forks / 5).clamp(0, 20).toDouble();
    final repoScore = (repos / 2).clamp(0, 30).toDouble();
    final langScore = (languages * 2).clamp(0, 10).toDouble();
    
    return (starScore + forkScore + repoScore + langScore).clamp(0.0, 100.0);
  }
  
  /// Fetch user profile from GitHub
  Future<GitHubProfile?> getUserProfile(String username) async {
    try {
      final response = await _dio.get(ApiEndpoints.userProfile(username));
      
      if (response.statusCode == 200) {
        return GitHubProfile.fromJson(response.data);
      }
      
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching profile for $username', e, stackTrace);
      return null;
    }
  }
  
  /// Search users by language or topic
  Future<List<String>> searchUsersByTopic({
    required String topic,
    int limit = 30,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.searchUsers,
        queryParameters: {
          'q': 'language:$topic',
          'per_page': limit,
          'sort': 'followers',
        },
      );
      
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((user) => user['login'] as String).toList();
      }
      
      return [];
    } catch (e, stackTrace) {
      AppLogger.e('Error searching users by topic: $topic', e, stackTrace);
      return [];
    }
  }
}

/// GitHub repository model
class GitHubRepository {
  final String name;
  final String fullName;
  final String? description;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final int size;
  final List<String> topics;
  final DateTime updatedAt;
  
  GitHubRepository({
    required this.name,
    required this.fullName,
    this.description,
    this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.size,
    required this.topics,
    required this.updatedAt,
  });
  
  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      language: json['language'] as String?,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      topics: (json['topics'] as List?)?.cast<String>() ?? [],
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// GitHub profile model
class GitHubProfile {
  final String login;
  final String? name;
  final String? bio;
  final String? location;
  final String? company;
  final String avatarUrl;
  final int publicRepos;
  final int followers;
  final int following;
  
  GitHubProfile({
    required this.login,
    this.name,
    this.bio,
    this.location,
    this.company,
    required this.avatarUrl,
    required this.publicRepos,
    required this.followers,
    required this.following,
  });
  
  factory GitHubProfile.fromJson(Map<String, dynamic> json) {
    return GitHubProfile(
      login: json['login'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      company: json['company'] as String?,
      avatarUrl: json['avatar_url'] as String,
      publicRepos: json['public_repos'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
    );
  }
}

/// Developer score model
class DeveloperScore {
  final String username;
  final int totalStars;
  final int totalForks;
  final int totalCommits;
  final int publicRepos;
  final int languageCount;
  final List<String> languages;
  final List<String> topics;
  final double activityScore;
  final DateTime lastUpdated;
  
  DeveloperScore({
    required this.username,
    required this.totalStars,
    required this.totalForks,
    required this.totalCommits,
    required this.publicRepos,
    required this.languageCount,
    required this.languages,
    required this.topics,
    required this.activityScore,
    required this.lastUpdated,
  });
  
  factory DeveloperScore.empty(String username) {
    return DeveloperScore(
      username: username,
      totalStars: 0,
      totalForks: 0,
      totalCommits: 0,
      publicRepos: 0,
      languageCount: 0,
      languages: [],
      topics: [],
      activityScore: 0,
      lastUpdated: DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'totalStars': totalStars,
      'totalForks': totalForks,
      'totalCommits': totalCommits,
      'publicRepos': publicRepos,
      'languageCount': languageCount,
      'languages': languages,
      'topics': topics,
      'activityScore': activityScore,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  factory DeveloperScore.fromJson(Map<String, dynamic> json) {
    return DeveloperScore(
      username: json['username'] as String,
      totalStars: json['totalStars'] as int? ?? 0,
      totalForks: json['totalForks'] as int? ?? 0,
      totalCommits: json['totalCommits'] as int? ?? 0,
      publicRepos: json['publicRepos'] as int? ?? 0,
      languageCount: json['languageCount'] as int? ?? 0,
      languages: (json['languages'] as List?)?.cast<String>() ?? [],
      topics: (json['topics'] as List?)?.cast<String>() ?? [],
      activityScore: (json['activityScore'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

