import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole {
  contributor,
  maintainer,
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? name,
    String? bio,
    String? githubHandle,
    String? location,
    List<String>? techStack,
    String? profileImageUrl,
    Map<String, dynamic>? githubData,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    bool? isOnboardingComplete,
    // Additional properties needed by the app
    String? id,
    String? username,
    String? displayName,
    String? photoURL,
    String? avatarUrl,
    String? githubUrl,
    String? githubUsername,
    UserRole? role,
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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Returns the best available profile image URL
  String? get effectivePhotoUrl => photoURL ?? avatarUrl ?? profileImageUrl;

  const UserModel._();
}

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    return object != null ? Timestamp.fromDate(object) : null;
  }
}

class UserRoleConverter implements JsonConverter<UserRole?, String?> {
  const UserRoleConverter();

  @override
  UserRole? fromJson(String? json) {
    if (json == null) return null;
    return UserRole.values.byName(json);
  }

  @override
  String? toJson(UserRole? object) {
    return object?.name;
  }
}
