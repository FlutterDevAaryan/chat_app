import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class FetchMessages extends ConversationEvent {
  final String chatId;

  FetchMessages(this.chatId);

  @override
  List<Object?> get props => <Object?>[chatId];
}

class SendMessage extends ConversationEvent {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;

  SendMessage(this.chatId, this.senderId, this.receiverId, this.message);

  @override
  List<Object?> get props => <Object?>[chatId, senderId, receiverId, message];
}
