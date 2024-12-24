import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;
  final bool isEditing;

   const ProfileLoaded({required this.userData, this.isEditing = false});

  @override
  List<Object?> get props => <Object?>[userData, isEditing];
}

class ProfileError extends ProfileState {
  final String error;

  const ProfileError(this.error);

  @override
  List<Object?> get props => <Object?>[error];
}
