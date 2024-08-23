import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/themes/app_color.dart';

part 'button_event.dart';
part 'button_state.dart';

class ButtonBloc extends Bloc<ButtonEvent, ButtonState> {
  ButtonBloc() : super(ButtonInitial()) {
    on<HoverEntered>(_onHoverEntered);
    on<HoverExited>(_onHoverExited);
    on<ButtonTapped>(_onButtonTapped);
  }

  void _onHoverEntered(HoverEntered event, Emitter<ButtonState> emit) {
    emit(ButtonHover());
  }

  void _onHoverExited(HoverExited event, Emitter<ButtonState> emit) {
    emit(ButtonInitial());
  }

  void _onButtonTapped(ButtonTapped event, Emitter<ButtonState> emit) async {
    emit(ButtonTappedState());
    await Future.delayed(const Duration(milliseconds: 100));
    emit(ButtonInitial());
  }
}