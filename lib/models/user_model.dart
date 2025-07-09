import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/logger.dart';

enum UserRole { contributor, maintainer }

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? username; // 🆕 Instagram-style username
  final String? photoURL;
  final String? githubUsername;
  final String? githubUrl;
  final String? bio;
  final List<String> skills;
  final List<String> interests;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final int? followers;
  final int? following;
  final int? repositories;
  final List<String>? topLanguages;
  final String? location;
  final String? company;
  final String? website;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.username,
    this.photoURL,
    this.githubUsername,
    this.githubUrl,
    this.bio,
    this.skills = const [],
    this.interests = const [],
    this.role = UserRole.contributor,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    this.followers,
    this.following,
    this.repositories,
    this.topLanguages,
    this.location,
    this.company,
    this.website,
  });

  /// 🔥 PRODUCTION-GRADE fromJson with bulletproof parsing
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: _parseString(json['id']) ?? '',
        email: _parseString(json['email']) ?? '',
        displayName:
            _parseString(json['name']) ?? _parseString(json['displayName']),
        username: _parseString(json['username']),
        photoURL:
            _parseString(json['avatar_url']) ?? _parseString(json['photoURL']),
        githubUsername: _parseString(json['github_username']) ??
            _parseString(json['githubUsername']),
        githubUrl:
            _parseString(json['github_url']) ?? _parseString(json['githubUrl']),
        bio: _parseString(json['bio']),
        skills: _parseStringList(json['skills']),
        interests: _parseStringList(json['interests']),
        role: _parseRole(json['role']),
        createdAt: _parseDateTime(json['created_at']) ??
            _parseDateTime(json['createdAt']) ??
            DateTime.now(),
        updatedAt: _parseDateTime(json['updated_at']) ??
            _parseDateTime(json['updatedAt']),
        isEmailVerified: _parseBool(json['is_email_verified']) ??
            _parseBool(json['isEmailVerified']) ??
            false,
        isProfileComplete: (_parseBool(json['is_profile_complete']) ??
                _parseBool(json['isProfileComplete'])) ==
            true,
        followers: _parseInt(json['followers']),
        following: _parseInt(json['following']),
        repositories: _parseInt(json['repositories']),
        topLanguages: _parseStringList(json['top_languages']) ??
            _parseStringList(json['topLanguages']),
        location: _parseString(json['location']),
        company: _parseString(json['company']),
        website: _parseString(json['website']),
      );
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Failed to parse UserModel from JSON',
        error: e,
        stackTrace: stackTrace,
      );

      // Fallback with minimal required fields to prevent crashes
      return UserModel(
        id: _parseString(json['id']) ?? 'unknown',
        email: _parseString(json['email']) ?? 'unknown@example.com',
        displayName: _parseString(json['name']) ?? 'Unknown User',
        username: _parseString(json['username']),
        createdAt: DateTime.now(),
      );
    }
  }

  /// 🛡️ SAFE PARSING METHODS - Production-grade error handling
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value.trim();
    return value.toString().trim().isEmpty ? null : value.toString().trim();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((e) => _parseString(e))
          .where((e) => e != null && e.isNotEmpty)
          .cast<String>()
          .toList();
    }
    return const [];
  }

  static UserRole _parseRole(dynamic value) {
    if (value == null) return UserRole.contributor;
    if (value is UserRole) return value;

    final roleString = _parseString(value)?.toLowerCase();
    switch (roleString) {
      case 'maintainer':
        return UserRole.maintainer;
      case 'contributor':
      default:
        return UserRole.contributor;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      // Handle Firestore Timestamp objects
      if (value is Timestamp) {
        return value.toDate();
      }

      // Handle ISO 8601 strings
      if (value is String) {
        return DateTime.parse(value);
      }

      // Handle milliseconds since epoch
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      // Handle Map with seconds/nanoseconds (Firestore format)
      if (value is Map) {
        final seconds = value['_seconds'] ?? value['seconds'];
        final nanoseconds = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds * 1000) + (nanoseconds ~/ 1000000),
          );
        }
      }

      AppLogger.logger.w('Unknown timestamp format: ${value.runtimeType}');
      return null;
    } catch (e) {
      AppLogger.logger.w('Failed to parse DateTime from: $value, error: $e');
      return null;
    }
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) return value != 0;
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// 🎯 Firestore-optimized toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': displayName,
      'username': username,
      'role': role.name,
      'avatar_url': photoURL,
      'bio': bio,
      'github_url': githubUrl,
      'github_username': githubUsername,
      'skills': skills,
      'interests': interests,
      'location': location,
      'company': company,
      'website': website,
      'followers': followers,
      'following': following,
      'repositories': repositories,
      'top_languages': topLanguages,
      'is_email_verified': isEmailVerified,
      'is_profile_complete': isProfileComplete,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 🔥 Firestore-safe data (with server timestamps)
  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'email': email,
      'name': displayName,
      'username': username,
      'role': role.name,
      'avatar_url': photoURL,
      'bio': bio,
      'github_url': githubUrl,
      'github_username': githubUsername,
      'skills': skills,
      'interests': interests,
      'location': location,
      'company': company,
      'website': website,
      'followers': followers,
      'following': following,
      'repositories': repositories,
      'top_languages': topLanguages,
      'is_email_verified': isEmailVerified,
      'is_profile_complete': isProfileComplete,
      // Let Firestore handle timestamps
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? username,
    String? photoURL,
    String? githubUsername,
    String? githubUrl,
    String? bio,
    List<String>? skills,
    List<String>? interests,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isProfileComplete,
    int? followers,
    int? following,
    int? repositories,
    List<String>? topLanguages,
    String? location,
    String? company,
    String? website,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      githubUsername: githubUsername ?? this.githubUsername,
      githubUrl: githubUrl ?? this.githubUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      repositories: repositories ?? this.repositories,
      topLanguages: topLanguages ?? this.topLanguages,
      location: location ?? this.location,
      company: company ?? this.company,
      website: website ?? this.website,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // 🎯 Convenience getters for compatibility
  String? get name => displayName;
  String? get avatarUrl => photoURL;
  String? get authMethod => 'email';

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, name: $displayName, role: $role}';
  }

  /// 🚀 Create instance from Firebase Auth User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser, {UserRole? role}) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified ?? false,
      role: role ?? UserRole.contributor,
      createdAt: DateTime.now(),
    );
  }

  /// 🛡️ Validate model data
  bool get isValid {
    return id.isNotEmpty &&
        email.isNotEmpty &&
        email.contains('@') &&
        (displayName?.isNotEmpty ?? false);
  }

  /// 🎯 Get completion percentage
  double get completionPercentage {
    int completedFields = 0;
    int totalFields = 7; // Essential fields for profile completion

    if (displayName?.isNotEmpty ?? false) completedFields++;
    if (username?.isNotEmpty ?? false) completedFields++;
    if (bio?.isNotEmpty ?? false) completedFields++;
    if (skills.isNotEmpty) completedFields++;
    if (githubUrl?.isNotEmpty ?? false) completedFields++;
    if (location?.isNotEmpty ?? false) completedFields++;
    if (isEmailVerified) completedFields++;

    return completedFields / totalFields;
  }
}
