import 'package:injectable/injectable.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<void> call() async {
    return await _repository.deleteAccount();
  }
}
