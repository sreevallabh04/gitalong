import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class RefreshStatsEvent extends ProfileEvent {}

class RefreshGitHubEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UserEntity updatedUser;

  const UpdateProfileEvent(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}
