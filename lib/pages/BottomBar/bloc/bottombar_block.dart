import 'package:flutter_bloc/flutter_bloc.dart';
import 'bottombar_event.dart';
import 'bottombar_state.dart';

class BottomNavBarBloc extends Bloc<BottombarEvent, BottombarState> {
  BottomNavBarBloc() : super(BottomNavBarInitial(currentIndex: 0)) {
    on<BottombarEvent>(_bottomNavBarEventToState);
  }

  void _bottomNavBarEventToState(BottombarEvent event, Emitter<BottombarState> emit) {
    if (event is BottomNavBar) {
      emit(BottomNavBarInitial(currentIndex: event.index));
    }
  }
}
 