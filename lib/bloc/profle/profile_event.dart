import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class FetchUserData extends ProfileEvent {}

class ToggleEditMode extends ProfileEvent {}

class UpdateUserDetails extends ProfileEvent {
  final String name;
  final String email;
  final String phone;

  const UpdateUserDetails({required this.name, required this.email, required this.phone});

  @override
  List<Object?> get props => <Object?>[name, email, phone];
}
