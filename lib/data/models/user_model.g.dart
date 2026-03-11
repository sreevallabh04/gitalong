// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      location: json['location'] as String?,
      company: json['company'] as String?,
      websiteUrl: json['website_url'] as String?,
      githubUrl: json['github_url'] as String?,
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      publicRepos: (json['public_repos'] as num?)?.toInt() ?? 0,
      languages:
          (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      interests:
          (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      if (instance.name != null) 'name': instance.name,
      if (instance.bio != null) 'bio': instance.bio,
      if (instance.avatarUrl != null) 'avatar_url': instance.avatarUrl,
      if (instance.location != null) 'location': instance.location,
      if (instance.company != null) 'company': instance.company,
      if (instance.websiteUrl != null) 'website_url': instance.websiteUrl,
      if (instance.githubUrl != null) 'github_url': instance.githubUrl,
      'followers': instance.followers,
      'following': instance.following,
      'public_repos': instance.publicRepos,
      'languages': instance.languages,
      'interests': instance.interests,
      'created_at': instance.createdAt.toIso8601String(),
      if (instance.lastActiveAt != null)
        'last_active_at': instance.lastActiveAt!.toIso8601String(),
    };
