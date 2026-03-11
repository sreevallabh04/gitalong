import 'package:equatable/equatable.dart';
import '../../../../domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatEvent {
  final String matchId;

  const LoadMessagesEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class SendMessageEvent extends ChatEvent {
  final String matchId;
  final String receiverId;
  final String content;

  const SendMessageEvent({
    required this.matchId,
    required this.receiverId,
    required this.content,
  });

  @override
  List<Object?> get props => [matchId, receiverId, content];
}

class MessageReceivedEvent extends ChatEvent {
  final MessageEntity message;

  const MessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
