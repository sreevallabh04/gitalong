import 'package:injectable/injectable.dart';

import '../../entities/match_entity.dart';
import '../../repositories/match_repository.dart';

/// Get matches use case
@injectable
class GetMatchesUseCase {
  final MatchRepository _matchRepository;
  
  const GetMatchesUseCase(this._matchRepository);
  
  /// Execute the use case
  Future<List<MatchEntity>> call({
    int limit = 50,
    String? cursor,
  }) async {
    return await _matchRepository.getMatches(
      limit: limit,
      cursor: cursor,
    );
  }
}



