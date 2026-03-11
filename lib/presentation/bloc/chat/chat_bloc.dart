import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/message_entity.dart';
import '../../../../domain/repositories/chat_repository.dart';
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

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _chatRepository.getMessages(matchId: event.matchId);
      _currentMessages = List.from(messages);
      
      // We sort the messages, but UI needs them in correct order (usually desc)
      emit(ChatLoaded(List.from(_currentMessages)));
      
      _messageSubscription?.cancel();
      _messageSubscription = _chatRepository.listenToMessages(event.matchId).listen(
        (message) {
          add(MessageReceivedEvent(message));
        },
        onError: (err) {
          // You might log the error
        }
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final newMsg = await _chatRepository.sendMessage(
        matchId: event.matchId,
        receiverId: event.receiverId,
        content: event.content,
      );
      
      // Optimistic insert / confirm insert 
      // check if it's already there to prevent duplication from listen block
      if (!_currentMessages.any((m) => m.id == newMsg.id)) {
        _currentMessages.insert(0, newMsg); // Or append depending on desc/asc
        emit(ChatLoaded(List.from(_currentMessages)));
      }
    } catch (e) {
      // Show error but state stays the same
      if (state is ChatLoaded) {
        // To easily trigger UI snackbar without losing messages, we can yield state again 
        // with an error mechanism, but here we just emit error and revert.
        // A better approach is using BlocListener for side effects. For simplicity:
      }
    }
  }

  void _onMessageReceived(MessageReceivedEvent event, Emitter<ChatState> emit) {
    if (!_currentMessages.any((m) => m.id == event.message.id)) {
      _currentMessages.insert(0, event.message); // Assuming list is built with reverse: true
      emit(ChatLoaded(List.from(_currentMessages)));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
