import 'package:equatable/equatable.dart';

abstract class AllUsersEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

class FetchAllUsers extends AllUsersEvent {}

class StartChatWithUser extends AllUsersEvent {
  final String currentUserId;
  final Map<String, dynamic> selectedUser;

  StartChatWithUser(this.currentUserId, this.selectedUser);

  @override
  List<Object> get props => <Object>[currentUserId, selectedUser];
}
