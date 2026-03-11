import 'package:injectable/injectable.dart';

import '../../entities/swipe_entity.dart';
import '../../entities/match_entity.dart';
import '../../repositories/swipe_repository.dart';

/// Swipe user use case
@injectable
class SwipeUserUseCase {
  final SwipeRepository _swipeRepository;
  
  const SwipeUserUseCase(this._swipeRepository);
  
  /// Execute the use case
  Future<MatchEntity?> call({
    required String swipedUserId,
    required SwipeAction action,
  }) async {
    // Record the swipe
    await _swipeRepository.swipeUser(
      swipedUserId: swipedUserId,
      action: action,
    );
    
    // Check for match
    if (action == SwipeAction.like || action == SwipeAction.superLike) {
      return await _swipeRepository.checkForMatch(swipedUserId);
    }
    
    return null;
  }
}



