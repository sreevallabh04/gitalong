import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../core/utils/production_logger.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? displayName;
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$UserModelFromJson(json);
    } catch (e, stackTrace) {
      ProductionLogger.error(
        'Failed to parse UserModel from JSON',
        error: e,
        stackTrace: stackTrace,
        data: {'json': json},
      );
      ProductionLogger.warning('Using fallback UserModel creation');

      // Provide fallback with minimal required fields
      return UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': displayName,
      'role': role.name,
      'avatar_url': photoURL,
      'bio': bio,
      'github_url': githubUrl,
      'skills': skills,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Method to create Firestore-safe data (without client timestamps)
  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'email': email,
      'name': displayName,
      'role': role.name,
      'avatar_url': photoURL,
      'bio': bio,
      'github_url': githubUrl,
      'skills': skills,
      // Don't include timestamps - let Firestore handle these
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
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

  // Convenience getters for compatibility
  String? get name => displayName;
  String? get avatarUrl => photoURL;

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, name: $displayName, role: $role}';
  }
}

enum UserRole { contributor, maintainer }
