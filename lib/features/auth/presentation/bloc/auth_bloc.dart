import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/enums/verification_purpose.dart';
import '../../../navigation/presentation/components/side_navigation_drawer/bloc/side_navigation_drawer_bloc.dart';
import '../../domain/usecases/user_login.dart';
import '../../domain/usecases/user_logout.dart';
import '../../domain/usecases/user_register.dart';
import '../../domain/usecases/user_reset_password.dart';
import '../../domain/usecases/user_send_otp.dart';
import '../../domain/usecases/user_update_info.dart';
import '../../domain/usecases/user_verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// AuthBloc constructor
  /// This is where we set the initial state of our bloc
  AuthBloc({
    required UserRegister userRegister,
    required UserLogin userLogin,
    required UserSendOtp userSendOtp,
    required UserVerifyOtp userVerifyOtp,
    required UserResetPassword userResetPassword,
    required UserLogout userLogout,
    required UserUpdateInfo userUpdateInfo,
    required SideNavigationDrawerBloc sideNavigationDrawerBloc,
  })  : _userRegister = userRegister,
        _userLogin = userLogin,
        _userSendOtp = userSendOtp,
        _userVerifyOtp = userVerifyOtp,
        _userResetPassword = userResetPassword,
        _userLogout = userLogout,
        _userUpdateInfo = userUpdateInfo,
        _sideNavigationDrawerBloc = sideNavigationDrawerBloc,
        super(AuthInitial()) {
    /// Event Handler - register the event via on<Event> API
    on<AuthRegister>(_onRegister);
    on<AuthLogin>(_onLogin);
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthResetPassword>(_onResetPassword);
    on<AuthLogout>(_onLogout);
    on<UpdateUserInfo>(_onUpdateUserInfo);
  }

  /// UserRegister UseCase
  final UserRegister _userRegister;

  /// UserLogin UserCase
  final UserLogin _userLogin;

  /// UserSendOtp UseCase
  final UserSendOtp _userSendOtp;

  /// UserVerifyOtp UseCase
  final UserVerifyOtp _userVerifyOtp;

  /// UserResetPassword UseCase
  final UserResetPassword _userResetPassword;

  /// UserLogout UseCase
  final UserLogout _userLogout;

  final UserUpdateInfo _userUpdateInfo;

  final SideNavigationDrawerBloc _sideNavigationDrawerBloc;

  void _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final response = await _userRegister(
      UserRegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      ),
    );

    print('Bloc register event: ${event.role}');

    response.fold(
      (l) => emit(AuthFailure(message: l.message)),
      (r) => emit(AuthSuccess(data: r)),
    );
  }

  void _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final response = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    response.fold(
      (l) {
        if (l.message.contains('User is not authenticated.')) {
          emit(OtpRequired(email: event.email));
        } else {
          emit(AuthFailure(message: l.message));
        }
      },
      (r) => emit(AuthSuccess(data: r)),
    );
  }

  void _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final response = await _userSendOtp(
      event.email,
    );

    response.fold(
      (l) => emit(AuthFailure(message: l.message)),
      (r) => emit(OtpSent(email: event.email)),
    );
  }

  void _onVerifyOtp(AuthVerifyOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    print(event.otp);

    final response = await _userVerifyOtp(
      UserVerifyOtpParams(
        email: event.email,
        otp: event.otp,
      ),
    );

    response.fold(
      (l) => emit(AuthFailure(message: l.message)),
      (r) => emit(AuthSuccess(data: r)),
    );
  }

  void _onResetPassword(
      AuthResetPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final response = await _userResetPassword(
      UserResetPasswordParams(
        email: event.email,
        password: event.password,
      ),
    );

    response.fold(
      (l) => emit(AuthFailure(message: l.message)),
      (r) => emit(AuthSuccess(data: r)),
    );
  }

  void _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    await _userLogout(event.token);

    print(state);
    emit(Unauthenticated());

    // to reset persistent navigation [redirects to where you logout]
    _sideNavigationDrawerBloc.add(const SideNavigationItemTapped(index: 0));
    print(state);
    // response.fold(
    //   (l) => emit(AuthFailure(message: l.message)),
    //   (r) => emit(Unauthenticated()),
    // );
  }

  void _onUpdateUserInfo(UpdateUserInfo event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final response = await _userUpdateInfo(
      UserUpdateInfoParams(
        id: event.id,
        profileImage: event.profileImage,
        password: event.password,
      ),
    );

    response.fold(
      (l) => emit(AuthFailure(message: l.message)),
      (r) => emit(
        UserInfoUpdated(updatedUser: r),
      ),
    );
  }
}
// Difference between Cubit and Bloc:
// Cubit - emits new state through functions
// Bloc - receives an event, then processes that event, and emits new state based on the processed event
