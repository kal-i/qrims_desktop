part of 'button_bloc.dart';

sealed class ButtonEvent {}

final class HoverEntered extends ButtonEvent {}

final class HoverExited extends ButtonEvent {}

final class ButtonTapped extends ButtonEvent {}