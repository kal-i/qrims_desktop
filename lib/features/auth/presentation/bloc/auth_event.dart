part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// We're attaching data to our event since it is the one we'll trigger
final class AuthRegister extends AuthEvent {
  const AuthRegister({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final String name;
  final String email;
  final String password;
  final Role role;

  @override
  List<Object> get props => [
        name,
        email,
        password,
        role,
      ];
}

final class AuthLogin extends AuthEvent {
  const AuthLogin({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [
        email,
        password,
      ];
}

final class AuthSendOtp extends AuthEvent {
  const AuthSendOtp({
    required this.email,
  });

  final String email;

  @override
  List<Object> get props => [
        email,
      ];
}

final class AuthVerifyOtp extends AuthEvent {
  const AuthVerifyOtp({
    required this.email,
    required this.otp,
    required this.purpose,
  });

  final String email;
  final String otp;
  final VerificationPurpose purpose;

  @override
  List<Object> get props => [
        email,
        otp,
        purpose,
      ];
}

final class AuthResetPassword extends AuthEvent {
  const AuthResetPassword({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

final class AuthLogout extends AuthEvent {
  const AuthLogout({
    required this.token,
  });

  final String token;
}

final class UpdateUserInfo extends AuthEvent {
  const UpdateUserInfo({
    required this.id,
    this.profileImage,
    this.password,
  });

  final String id;
  final String? profileImage;
  final String? password;
}
