import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Update user profile use case
@injectable
class UpdateUserProfileUseCase {
  final UserRepository _userRepository;

  const UpdateUserProfileUseCase(this._userRepository);

  Future<UserEntity> call(UserEntity user) async {
    return await _userRepository.updateUserProfile(user);
  }
}
