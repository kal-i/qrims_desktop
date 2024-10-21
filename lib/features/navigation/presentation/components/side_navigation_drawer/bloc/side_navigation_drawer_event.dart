part of 'side_navigation_drawer_bloc.dart';

sealed class SideNavigationDrawerEvent extends Equatable {
  const SideNavigationDrawerEvent();

  @override
  List<Object> get props => [];
}

final class SideNavigationItemTapped extends SideNavigationDrawerEvent {
  const SideNavigationItemTapped({
    required this.index,
  });

  final int index;

  @override
  List<Object> get props => [
        index,
      ];
}

final class SideNavigationToggleMinimize extends SideNavigationDrawerEvent {}

final class ResetSideNavigationState extends SideNavigationDrawerEvent {}
