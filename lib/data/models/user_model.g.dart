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
  lastActiveAt:
      json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
  matchScore: (json['match_score'] as num?)?.toDouble(),
  scoreBreakdown: json['score_breakdown'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  if (instance.name case final value?) 'name': value,
  if (instance.bio case final value?) 'bio': value,
  if (instance.avatarUrl case final value?) 'avatar_url': value,
  if (instance.location case final value?) 'location': value,
  if (instance.company case final value?) 'company': value,
  if (instance.websiteUrl case final value?) 'website_url': value,
  if (instance.githubUrl case final value?) 'github_url': value,
  'followers': instance.followers,
  'following': instance.following,
  'public_repos': instance.publicRepos,
  'languages': instance.languages,
  'interests': instance.interests,
  'created_at': instance.createdAt.toIso8601String(),
  if (instance.lastActiveAt?.toIso8601String() case final value?)
    'last_active_at': value,
  if (instance.matchScore case final value?) 'match_score': value,
  if (instance.scoreBreakdown case final value?) 'score_breakdown': value,
};
