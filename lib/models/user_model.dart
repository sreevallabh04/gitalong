import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'user_roles.dart' as roles;


@immutable
class UserModel {

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.bio,
    this.githubHandle,
    this.location,
    this.techStack,
    this.profileImageUrl,
    this.githubData,
    this.createdAt,
    this.updatedAt,
    this.isOnboardingComplete,
    this.id,
    this.username,
    this.displayName,
    this.photoURL,
    this.avatarUrl,
    this.githubUrl,
    this.githubUsername,
    this.role,
    this.skills,
    this.interests,
    this.followers,
    this.following,
    this.repositories,
    this.company,
    this.website,
    this.topLanguages,
    this.authMethod,
    this.isEmailVerified,
    this.isProfileComplete,
    this.security,
    this.privacy,
    this.statistics,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      githubHandle: json['githubHandle'] as String?,
      location: json['location'] as String?,
      techStack: (json['techStack'] as List<dynamic>?)?.cast<String>(),
      profileImageUrl: json['profileImageUrl'] as String?,
      githubData: json['githubData'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      isOnboardingComplete: json['isOnboardingComplete'] as bool?,
      id: json['id'] as String?,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      githubUsername: json['githubUsername'] as String?,
      role: json['role'] != null
          ? roles.UserRole.values.byName(json['role'] as String)
          : null,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>(),
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      followers: json['followers'] as int?,
      following: json['following'] as int?,
      repositories: json['repositories'] as int?,
      company: json['company'] as String?,
      website: json['website'] as String?,
      topLanguages: (json['topLanguages'] as List<dynamic>?)?.cast<String>(),
      authMethod: json['authMethod'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      isProfileComplete: json['isProfileComplete'] as bool?,
      security: json['security'] as Map<String, dynamic>?,
      privacy: json['privacy'] as Map<String, dynamic>?,
      statistics: json['statistics'] as Map<String, dynamic>?,
    );
  final String uid;
  final String email;
  final String? name;
  final String? bio;
  final String? githubHandle;
  final String? location;
  final List<String>? techStack;
  final String? profileImageUrl;
  final Map<String, dynamic>? githubData;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isOnboardingComplete;
  // Additional properties needed by the app
  final String? id;
  final String? username;
  final String? displayName;
  final String? photoURL;
  final String? avatarUrl;
  final String? githubUrl;
  final String? githubUsername;
  final roles.UserRole? role;
  final List<String>? skills;
  final List<String>? interests;
  final int? followers;
  final int? following;
  final int? repositories;
  final String? company;
  final String? website;
  final List<String>? topLanguages;
  final String? authMethod;
  final bool? isEmailVerified;
  final bool? isProfileComplete;
  // Security and profile enhancements
  final Map<String, dynamic>? security;
  final Map<String, dynamic>? privacy;
  final Map<String, dynamic>? statistics;

  Map<String, dynamic> toJson() => {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'githubHandle': githubHandle,
      'location': location,
      'techStack': techStack,
      'profileImageUrl': profileImageUrl,
      'githubData': githubData,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isOnboardingComplete': isOnboardingComplete,
      'id': id,
      'username': username,
      'displayName': displayName,
      'photoURL': photoURL,
      'avatarUrl': avatarUrl,
      'githubUrl': githubUrl,
      'githubUsername': githubUsername,
      'role': role?.name,
      'skills': skills,
      'interests': interests,
      'followers': followers,
      'following': following,
      'repositories': repositories,
      'company': company,
      'website': website,
      'topLanguages': topLanguages,
      'authMethod': authMethod,
      'isEmailVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
      'security': security,
      'privacy': privacy,
      'statistics': statistics,
    };

  // Returns the best available profile image URL
  String? get effectivePhotoUrl => photoURL ?? avatarUrl ?? profileImageUrl;

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? bio,
    String? githubHandle,
    String? location,
    List<String>? techStack,
    String? profileImageUrl,
    Map<String, dynamic>? githubData,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnboardingComplete,
    String? id,
    String? username,
    String? displayName,
    String? photoURL,
    String? avatarUrl,
    String? githubUrl,
    String? githubUsername,
    roles.UserRole? role,
    List<String>? skills,
    List<String>? interests,
    int? followers,
    int? following,
    int? repositories,
    String? company,
    String? website,
    List<String>? topLanguages,
    String? authMethod,
    bool? isEmailVerified,
    bool? isProfileComplete,
    Map<String, dynamic>? security,
    Map<String, dynamic>? privacy,
    Map<String, dynamic>? statistics,
  }) => UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      githubHandle: githubHandle ?? this.githubHandle,
      location: location ?? this.location,
      techStack: techStack ?? this.techStack,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      githubData: githubData ?? this.githubData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      githubUsername: githubUsername ?? this.githubUsername,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      repositories: repositories ?? this.repositories,
      company: company ?? this.company,
      website: website ?? this.website,
      topLanguages: topLanguages ?? this.topLanguages,
      authMethod: authMethod ?? this.authMethod,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      security: security ?? this.security,
      privacy: privacy ?? this.privacy,
      statistics: statistics ?? this.statistics,
    );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, name: $name)';
}

