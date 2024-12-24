import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<TabChangedEvent>((TabChangedEvent event, Emitter<HomeState> emit) {
      emit(TabChangedState(event.newIndex));
    });
  }
}
