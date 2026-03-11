import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/entities/match_entity.dart';

abstract class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<UserEntity> users;

  const DiscoverLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class DiscoverEmpty extends DiscoverState {}

class DiscoverError extends DiscoverState {
  final String message;

  const DiscoverError(this.message);

  @override
  List<Object?> get props => [message];
}

class DiscoverMatch extends DiscoverState {
  final MatchEntity match;
  final List<UserEntity> remainingUsers;

  const DiscoverMatch({
    required this.match,
    required this.remainingUsers,
  });

  @override
  List<Object?> get props => [match, remainingUsers];
}
