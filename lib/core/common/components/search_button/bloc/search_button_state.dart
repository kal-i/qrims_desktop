part of 'search_button_bloc.dart';

sealed class SearchButtonState {}

final class SearchButtonCollapsed extends SearchButtonState {}

final class SearchButtonExpanded extends SearchButtonState {}