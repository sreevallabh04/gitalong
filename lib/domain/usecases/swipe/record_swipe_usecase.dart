import 'package:injectable/injectable.dart';

import '../../entities/match_entity.dart';
import '../../repositories/match_repository.dart';

@injectable
/// Use case for recording swipe actions
class RecordSwipeUseCase {
  /// Creates the use case
  RecordSwipeUseCase(this._matchRepository);

  final MatchRepository _matchRepository;

  /// Records a swipe action
  Future<SwipeActionEntity> call(SwipeActionEntity swipe) =>
      _matchRepository.recordSwipe(swipe);
}
