import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'custom_auth_password_text_box_event.dart';

class CustomAuthPasswordTextBoxBloc extends Bloc<CustomAuthPasswordTextBoxEvent, bool> {
  CustomAuthPasswordTextBoxBloc() : super(false) {
    on<ToggleVisibility>(_onToggleVisibility);
    on<ResetVisibility>(_onResetVisibility);
  }

  void _onToggleVisibility(ToggleVisibility event, Emitter<bool> emit) {
    emit (state == false ? true : false);
  }

  void _onResetVisibility(ResetVisibility event, Emitter<bool> emit) {
    emit(false);
  }
}
