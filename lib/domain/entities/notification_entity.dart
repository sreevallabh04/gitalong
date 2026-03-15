import 'package:equatable/equatable.dart';

/// In-app notification for "You matched with X!"
class NewMatchNotification extends Equatable {
  final String matchId;
  final String fromUserName;

  const NewMatchNotification({
    required this.matchId,
    required this.fromUserName,
  });

  @override
  List<Object?> get props => [matchId, fromUserName];
}
