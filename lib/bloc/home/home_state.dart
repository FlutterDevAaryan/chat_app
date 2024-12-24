import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class HomeInitial extends HomeState {
  final int currentTabIndex;

  HomeInitial({this.currentTabIndex = 0});

  @override
  List<Object?> get props => <Object?>[currentTabIndex];
}

class TabChangedState extends HomeState {
  final int currentTabIndex;

  TabChangedState(this.currentTabIndex);

  @override
  List<Object?> get props => <Object?>[currentTabIndex];
}
