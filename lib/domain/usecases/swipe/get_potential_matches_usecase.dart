import 'package:injectable/injectable.dart';

import '../../repositories/match_repository.dart';

@injectable
/// Use case for getting potential matches for swiping
class GetPotentialMatchesUseCase {
  /// Creates the use case
  GetPotentialMatchesUseCase(this._matchRepository);

  final MatchRepository _matchRepository;

  /// Gets potential matches for a user
  Future<List<dynamic>> call(String userId, {int limit = 10}) =>
      _matchRepository.getPotentialMatches(userId, limit: limit);
}
