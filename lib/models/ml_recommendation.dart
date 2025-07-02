import 'github_user_model.dart';

/// ML recommendation model for user matching
class MLRecommendation {
  final String uid;
  final double matchScore;
  final GitHubUser user;
  final List<String> matchReasons;

  // Convenience getter for compatibility with swipe screen
  String get targetUserId => uid;

  const MLRecommendation({
    required this.uid,
    required this.matchScore,
    required this.user,
    this.matchReasons = const [],
  });

  factory MLRecommendation.fromJson(Map<String, dynamic> json) {
    return MLRecommendation(
      uid: json['uid'] as String,
      matchScore: (json['match_score'] as num).toDouble(),
      user: GitHubUser.fromJson(json['user'] as Map<String, dynamic>),
      matchReasons: List<String>.from(json['match_reasons'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'match_score': matchScore,
      'user': user.toJson(),
      'match_reasons': matchReasons,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MLRecommendation &&
        other.uid == uid &&
        other.matchScore == matchScore &&
        other.user == user &&
        other.matchReasons == matchReasons;
  }

  @override
  int get hashCode => Object.hash(uid, matchScore, user, matchReasons);

  @override
  String toString() {
    return 'MLRecommendation(uid: $uid, matchScore: $matchScore, user: $user, matchReasons: $matchReasons)';
  }

  /// Creates a copy with updated values
  MLRecommendation copyWith({
    String? uid,
    double? matchScore,
    GitHubUser? user,
    List<String>? matchReasons,
  }) {
    return MLRecommendation(
      uid: uid ?? this.uid,
      matchScore: matchScore ?? this.matchScore,
      user: user ?? this.user,
      matchReasons: matchReasons ?? this.matchReasons,
    );
  }
}
