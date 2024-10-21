import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/remote/auth_remote_data_source.dart';
import '../../../../core/models/mobile_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;

  /// According to the Liskov substitution principle,
  /// we can replace UserEntity with UserModel because
  /// UserEntity is a parent of UserModel
  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    Role? role,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      print('RepositoryImpl received userModel: $userModel');
      return right(userModel); // means we're returning an user
    } on ServerException catch (e) {
      print('RepositoryImpl Exception: $e');
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Authorization
      if (userModel is MobileUserModel) {
        throw const ServerException('Unauthorized User.');
      }

      return right(userModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> sendEmailOtp({
    required String email,
  }) async {
    try {
      final response = await remoteDataSource.sendEmailOtp(
        email: email,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await remoteDataSource.verifyEmailOtp(
        email: email,
        otp: otp,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.resetPassword(
        email: email,
        password: password,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout({
    required String token,
  }) async {
    try {
      final response = await remoteDataSource.logout(
        token: token,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> bearerLogin({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.bearerLogin(
        email: email,
        password: password,
      );

      // Authorization
      if (userModel is MobileUserModel) {
        throw const ServerException('Unauthorized User.');
      }

      print(userModel);

      return right(userModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserInformation({
    required String id,
    String? profileImage,
    String? password,
  }) async {
    try {
      final response = await remoteDataSource.updateUserInformation(
        id: id,
        profileImage: profileImage,
        password: password,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}

// change password
// send otp
// verify otp

// enter email -> send otp
// that page accepts an email then the otp -> verify otp
// can also send there otp
