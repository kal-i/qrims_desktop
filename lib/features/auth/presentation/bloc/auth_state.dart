part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

/// Prolly make this a generic type
/// or just create another var to represent other type of succ but it's kinda weird so maybe the first opt is much better
final class AuthSuccess<T> extends AuthState {
  final T data;

  const AuthSuccess({
    required this.data,
  });

  @override
  List<Object?> get props => [
        data,
      ];
}

// final class AuthSuccess extends AuthState {
//   final UserEntity userEntity;
//
//   const AuthSuccess({
//     required this.userEntity,
//   });
//
//   @override
//   List<Object> get props => [userEntity];
// }

final class AuthFailure extends AuthState {
  const AuthFailure({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class Unauthenticated extends AuthState {}

final class OtpRequired extends AuthState {
  const OtpRequired({
    required this.email,
  });

  final String email;

  @override
  List<Object?> get props => [email];
}

final class OtpSent extends AuthState {
  const OtpSent({
    required this.email,
  });

  final String email;

  @override
  List<Object?> get props => [email];
}

final class UserInfoUpdated<T> extends AuthState {
  const UserInfoUpdated({
    required this.updatedUser,
  });

  final T updatedUser;

  @override
  List<Object?> get props => [
        updatedUser,
      ];
}
