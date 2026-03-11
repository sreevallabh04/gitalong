import 'package:injectable/injectable.dart';

import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

/// Send message use case
@injectable
class SendMessageUseCase {
  final ChatRepository _chatRepository;
  
  const SendMessageUseCase(this._chatRepository);
  
  /// Execute the use case
  Future<MessageEntity> call({
    required String matchId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    return await _chatRepository.sendMessage(
      matchId: matchId,
      receiverId: receiverId,
      content: content,
      type: type,
    );
  }
}



