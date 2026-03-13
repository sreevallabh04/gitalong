import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/message_entity.dart';
import '../../../../domain/repositories/chat_repository.dart';
import '../../../../core/utils/logger.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  StreamSubscription<MessageEntity>? _messageSubscription;
  List<MessageEntity> _currentMessages = [];

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages =
          await _chatRepository.getMessages(matchId: event.matchId);
      _currentMessages = List.from(messages);
      emit(ChatLoaded(List.from(_currentMessages)));

      // Mark all messages in this chat as read
      try {
        await _chatRepository.markAllMessagesAsRead(event.matchId);
      } catch (e) {
        if (kDebugMode) AppLogger.w('Failed to mark messages as read: $e');
      }

      _messageSubscription?.cancel();
      _messageSubscription =
          _chatRepository.listenToMessages(event.matchId).listen(
        (message) {
          add(MessageReceivedEvent(message));
        },
        onError: (err) {
          AppLogger.w('Message stream error: $err');
        },
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final newMsg = await _chatRepository.sendMessage(
        matchId: event.matchId,
        receiverId: event.receiverId,
        content: event.content,
      );

      if (!_currentMessages.any((m) => m.id == newMsg.id)) {
        _currentMessages.insert(0, newMsg);
        emit(ChatLoaded(List.from(_currentMessages)));
      }
    } catch (e) {
      emit(ChatSendError(
        messages: List.from(_currentMessages),
        error: 'Failed to send message. Please try again.',
      ));
      emit(ChatLoaded(List.from(_currentMessages)));
    }
  }

  void _onMessageReceived(
      MessageReceivedEvent event, Emitter<ChatState> emit) {
    if (!_currentMessages.any((m) => m.id == event.message.id)) {
      _currentMessages.insert(0, event.message);
      emit(ChatLoaded(List.from(_currentMessages)));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
