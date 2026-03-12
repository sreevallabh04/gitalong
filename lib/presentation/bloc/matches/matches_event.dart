import 'package:equatable/equatable.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatchesEvent extends MatchesEvent {}

class RefreshMatchesEvent extends MatchesEvent {}
