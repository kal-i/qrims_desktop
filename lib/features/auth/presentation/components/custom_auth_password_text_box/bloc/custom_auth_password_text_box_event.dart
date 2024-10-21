part of 'custom_auth_password_text_box_bloc.dart';

sealed class CustomAuthPasswordTextBoxEvent extends Equatable {
  const CustomAuthPasswordTextBoxEvent();

  @override
  List<Object> get props => [];
}

final class ToggleVisibility extends CustomAuthPasswordTextBoxEvent {}

final class ResetVisibility extends CustomAuthPasswordTextBoxEvent {}
