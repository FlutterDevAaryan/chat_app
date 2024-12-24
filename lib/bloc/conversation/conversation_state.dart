import 'package:equatable/equatable.dart';

abstract class ConversationState extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
   final List<Map<String, dynamic>> messagess;

  ConversationLoaded(this.messagess);

  @override
  List<Object?> get props => <Object?>[messagess];
}

class ConversationError extends ConversationState {
  final String message;

  ConversationError(this.message);

  @override
  List<Object?> get props => <Object?>[message];
}

class MessageSent extends ConversationState {}
