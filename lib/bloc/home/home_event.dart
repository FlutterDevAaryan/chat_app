import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class TabChangedEvent extends HomeEvent {
  final int newIndex;

  TabChangedEvent(this.newIndex);

  @override
  List<Object?> get props => <Object?>[newIndex];
}
