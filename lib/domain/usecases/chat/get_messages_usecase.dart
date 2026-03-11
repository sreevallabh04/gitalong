import 'package:injectable/injectable.dart';

import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

/// Get messages use case
@injectable
class GetMessagesUseCase {
  final ChatRepository _chatRepository;
  
  const GetMessagesUseCase(this._chatRepository);
  
  /// Execute the use case
  Future<List<MessageEntity>> call({
    required String matchId,
    int limit = 50,
    String? cursor,
  }) async {
    return await _chatRepository.getMessages(
      matchId: matchId,
      limit: limit,
      cursor: cursor,
    );
  }
}



