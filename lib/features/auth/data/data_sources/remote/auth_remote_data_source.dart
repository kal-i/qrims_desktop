import '../../../../../core/enums/role.dart';
import '../../../../../core/models/user.dart';

/// A contract
/// This interface is only concerned with the calls made to the external db
abstract interface class AuthRemoteDataSource {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    Role? role,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<bool> sendEmailOtp({
    required String email,
  });

  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<bool> resetPassword({
    required String email,
    required String password,
  });

  Future<void> logout({
    required String token,
  });

  Future<void> storeToken({
    required String token,
  });

  Future<String?> retrieveToken();

  Future<void> clearToken();

  Future<UserModel> bearerLogin({
    required String email,
    required String password,
  });

  Future<UserModel> updateUserInformation({
    required String id,
    String? profileImage,
    String? password,
  });
}

/// the very basis of clean archi is to depend on interfaces than concrete impl
/// so we don't have to care about the details presented inside
/// cause we just depend on the contract [interface]
