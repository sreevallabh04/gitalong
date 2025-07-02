import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? avatarUrl;
  final String? bio;
  final String? githubUrl;
  final List<String> skills;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.githubUrl,
    this.skills = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to parse timestamps from Firestore
      DateTime parseTimestamp(dynamic value) {
        if (value == null) return DateTime.now();

        // Handle Firestore Timestamp objects
        if (value is Timestamp) {
          return value.toDate();
        }

        // Handle ISO string
        if (value is String) {
          return DateTime.parse(value);
        }

        // Handle milliseconds since epoch
        if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        }

        // Fallback
        return DateTime.now();
      }

      return UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: UserRole.values.byName(json['role'] as String? ?? 'contributor'),
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        githubUrl: json['github_url'] as String?,
        skills: List<String>.from(json['skills'] ?? []),
        createdAt: parseTimestamp(json['created_at']),
        updatedAt: parseTimestamp(json['updated_at']),
      );
    } catch (e, stackTrace) {
      // Log the error but return a valid UserModel with defaults
      print('Error parsing UserModel from JSON: $e');
      print('JSON data: $json');

      return UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? 'Unknown User',
        role: UserRole.contributor,
        skills: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'github_url': githubUrl,
      'skills': skills,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Method to create Firestore-safe data (without client timestamps)
  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'github_url': githubUrl,
      'skills': skills,
      // Don't include timestamps - let Firestore handle these
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? avatarUrl,
    String? bio,
    String? githubUrl,
    List<String>? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      githubUrl: githubUrl ?? this.githubUrl,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, name: $name, role: $role}';
  }
}

enum UserRole { contributor, maintainer }
