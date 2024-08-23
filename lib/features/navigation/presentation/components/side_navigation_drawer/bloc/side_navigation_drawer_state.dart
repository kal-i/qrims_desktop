part of 'side_navigation_drawer_bloc.dart';

class SideNavigationDrawerState extends Equatable {
  const SideNavigationDrawerState({
    this.selectedIndex = 0,
    this.isMinimized = true,
  });

  final int selectedIndex;
  final bool isMinimized;

  SideNavigationDrawerState copyWith({
    int? selectedIndex,
    bool? isMinimized,
  }) {
    /// if there is a change, use the params' values otherwise the initial value (this)
    return SideNavigationDrawerState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isMinimized: isMinimized ?? this.isMinimized,
    );
  }

  @override
  List<Object?> get props => [
        selectedIndex,
        isMinimized,
      ];
}
