import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Get recommended users use case
@injectable
class GetRecommendedUsersUseCase {
  final UserRepository _userRepository;
  
  const GetRecommendedUsersUseCase(this._userRepository);
  
  /// Execute the use case
  Future<List<UserEntity>> call({
    int limit = 20,
    String? cursor,
  }) async {
    return await _userRepository.getRecommendedUsers(
      limit: limit,
      cursor: cursor,
    );
  }
}



