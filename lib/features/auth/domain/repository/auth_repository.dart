import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/error/failure.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    Role? role,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> sendEmailOtp({
    required String email,
  });

  Future<Either<Failure, bool>> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout({
    required String token,
  });

  Future<Either<Failure, UserEntity>> bearerLogin({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> updateUserInformation({
    required String id,
    String? profileImage,
    String? password,
  });
}

// only mobile user should be able to login, so probably add authorization
// for otp - just concatenate the value of 4 fields

// abstract class - used to provide a base class for concrete subclasses
// abstract interface class - used to define a set of methods that a class must implement
