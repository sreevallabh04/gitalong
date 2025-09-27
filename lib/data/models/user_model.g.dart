// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  location: json['location'] as String?,
  website: json['website'] as String?,
  company: json['company'] as String?,
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
  followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
  repositoriesCount: (json['repositoriesCount'] as num?)?.toInt() ?? 0,
  contributionsCount: (json['contributionsCount'] as num?)?.toInt() ?? 0,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
  isVerified: json['isVerified'] as bool? ?? false,
  preferences: UserPreferencesModel.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'displayName': instance.displayName,
  'email': instance.email,
  if (instance.avatarUrl case final value?) 'avatarUrl': value,
  if (instance.bio case final value?) 'bio': value,
  if (instance.location case final value?) 'location': value,
  if (instance.website case final value?) 'website': value,
  if (instance.company case final value?) 'company': value,
  'skills': instance.skills,
  'languages': instance.languages,
  'followersCount': instance.followersCount,
  'followingCount': instance.followingCount,
  'repositoriesCount': instance.repositoriesCount,
  'contributionsCount': instance.contributionsCount,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'lastActiveAt': instance.lastActiveAt.toIso8601String(),
  'isVerified': instance.isVerified,
  'preferences': instance.preferences.toJson(),
};

UserPreferencesModel _$UserPreferencesModelFromJson(
  Map<String, dynamic> json,
) => UserPreferencesModel(
  showEmail: json['showEmail'] as bool? ?? true,
  showLocation: json['showLocation'] as bool? ?? true,
  showCompany: json['showCompany'] as bool? ?? true,
  allowDirectMessages: json['allowDirectMessages'] as bool? ?? true,
  allowProjectInvites: json['allowProjectInvites'] as bool? ?? true,
  interestedTechnologies:
      (json['interestedTechnologies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  preferredCollaborationType:
      json['preferredCollaborationType'] as String? ?? 'collaboration',
  maxDistanceKm: (json['maxDistanceKm'] as num?)?.toInt() ?? 50,
);

Map<String, dynamic> _$UserPreferencesModelToJson(
  UserPreferencesModel instance,
) => <String, dynamic>{
  'showEmail': instance.showEmail,
  'showLocation': instance.showLocation,
  'showCompany': instance.showCompany,
  'allowDirectMessages': instance.allowDirectMessages,
  'allowProjectInvites': instance.allowProjectInvites,
  'interestedTechnologies': instance.interestedTechnologies,
  'preferredCollaborationType': instance.preferredCollaborationType,
  'maxDistanceKm': instance.maxDistanceKm,
};
