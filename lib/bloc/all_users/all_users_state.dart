import 'package:equatable/equatable.dart';

abstract class AllUsersState extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class AllUsersLoading extends AllUsersState {}

class AllUsersLoaded extends AllUsersState {
  final List<Map<String, dynamic>> users;

  AllUsersLoaded(this.users);

  @override
  List<Object?> get props => <Object?>[users];
}

class AllUsersError extends AllUsersState {
  final String message;

  AllUsersError(this.message);

  @override
  List<Object?> get props => <Object?>[message];
}

class ChatStarted extends AllUsersState {
  final String chatId;
  final Map<String, dynamic> selectedUser;

  ChatStarted(this.chatId, this.selectedUser);

  @override
  List<Object?> get props => <Object?>[chatId, selectedUser];
}
