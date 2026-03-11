import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Match entity
class MatchEntity extends Equatable {
  final String id;
  final UserEntity user;
  final DateTime matchedAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isRead;

  const MatchEntity({
    required this.id,
    required this.user,
    required this.matchedAt,
    this.lastMessage,
    this.lastMessageAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
    id,
    user,
    matchedAt,
    lastMessage,
    lastMessageAt,
    isRead,
  ];

  /// Copy with method
  MatchEntity copyWith({
    String? id,
    UserEntity? user,
    DateTime? matchedAt,
    String? lastMessage,
    DateTime? lastMessageAt,
    bool? isRead,
  }) {
    return MatchEntity(
      id: id ?? this.id,
      user: user ?? this.user,
      matchedAt: matchedAt ?? this.matchedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
