import 'github_user_model.dart';

/// ML recommendation model for user matching
class MLRecommendation {
  final String uid;
  final double matchScore;
  final GitHubUser user;

  const MLRecommendation({
    required this.uid,
    required this.matchScore,
    required this.user,
  });

  factory MLRecommendation.fromJson(Map<String, dynamic> json) {
    return MLRecommendation(
      uid: json['uid'] as String,
      matchScore: (json['match_score'] as num).toDouble(),
      user: GitHubUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'match_score': matchScore,
      'user': user.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MLRecommendation &&
        other.uid == uid &&
        other.matchScore == matchScore &&
        other.user == user;
  }

  @override
  int get hashCode => Object.hash(uid, matchScore, user);

  @override
  String toString() {
    return 'MLRecommendation(uid: $uid, matchScore: $matchScore, user: $user)';
  }

  /// Creates a copy with updated values
  MLRecommendation copyWith({
    String? uid,
    double? matchScore,
    GitHubUser? user,
  }) {
    return MLRecommendation(
      uid: uid ?? this.uid,
      matchScore: matchScore ?? this.matchScore,
      user: user ?? this.user,
    );
  }
}
