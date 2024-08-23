import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'side_navigation_drawer_event.dart';
part 'side_navigation_drawer_state.dart';

class SideNavigationDrawerBloc extends Bloc<SideNavigationDrawerEvent, SideNavigationDrawerState> {
  SideNavigationDrawerBloc() : super(const SideNavigationDrawerState()) {
    on<SideNavigationItemTapped>(_onItemTapped);
    on<SideNavigationToggleMinimize>(_onToggleMinimize);
  }

  void _onItemTapped(SideNavigationItemTapped event, Emitter<SideNavigationDrawerState> emit) {
    /// we use the copyWith method because we don't want unnecessary build/ changes when we trigger certain event
    emit(state.copyWith(selectedIndex: event.index));
  }

  void _onToggleMinimize(SideNavigationToggleMinimize event, Emitter<SideNavigationDrawerState> emit) {
    emit(state.copyWith(isMinimized: !state.isMinimized));
  }
}
