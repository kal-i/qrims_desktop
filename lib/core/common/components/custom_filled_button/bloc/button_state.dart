part of 'button_bloc.dart';

sealed class ButtonState {
  Color get color;
  Color get textColor;
}

final class ButtonInitial extends ButtonState {
  @override
  Color get color => AppColor.button;
  @override
  Color get textColor => AppColor.lightPrimary;
}

final class ButtonHover extends ButtonState {
  @override
  Color get color => AppColor.hover;
  @override
  Color get textColor => AppColor.lightPrimary;
}

final class ButtonTappedState extends ButtonState {
  @override
  Color get color => AppColor.tapped;
  @override
  Color get textColor => AppColor.lightPrimary;
}