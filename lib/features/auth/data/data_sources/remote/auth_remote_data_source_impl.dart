import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/enums/auth_status.dart';
import '../../../../../core/enums/role.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/user.dart';
import '../../../../../core/services/http_service.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    Role? role,
  }) async {
    try {
      Map<String, dynamic> params = {
        'name': name,
        'email': email,
        'password': password,
        'role': role?.toString().split('.').last, // I'll change this later on
      };

      print('RemoteDataSource register params: $params');

      final response = await httpService.post(
        endpoint: registerEP,
        params: params,
      );

      print('RemoteDataSource response: ${response.data}');

      if (response.statusCode != 200) {
        print('RemoteDataSource error status code: ${response.statusCode}');
        throw ServerException(response.statusMessage.toString());
      }

      // I know now, the response didn't match because it returns a msg and user
      final responseData = response.data as Map<String, dynamic>;
      print('res data: $responseData');
      // final userJson = response.data as Map<String, dynamic>;
      final userJson = responseData['user'];
      print(userJson);
      final userModel = UserModel.fromJson(userJson);

      print('RemoteDataSource userModel: $userModel');
      return userModel;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.data is String) {
          throw ServerException(
              e.response?.data
          );
        }

        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == 500 &&
            errorMessage == 'Email already exists.') {
          throw const ServerException('Email already exists.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      print('RemoteDataSource Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> params = {
        'email': email,
        'password': password,
      };

      final response = await httpService.post(
        endpoint: loginEP,
        params: params,
      );

      if (response.data == null) {
        throw const ServerException('User not found.');
      }

      if (response.statusCode == 200) {
        final userJson = response.data as Map<String, dynamic>;
        final userModel = UserModel.fromJson(userJson);

        print('auth remote ds imp: $userModel');

        if (userModel.authStatus == AuthStatus.unauthenticated) {
          throw const ServerException('User is not authenticated.');
        }

        return userModel;
      } else {
        throw ServerException(response.statusMessage.toString());
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.data is String) {
          throw ServerException(
              e.response?.data
          );
        }

        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == HttpStatus.unauthorized &&
            errorMessage == 'Invalid user credential.') {
          throw const ServerException('Invalid user credential.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      print('RemoteDataSource Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> sendEmailOtp({
    required String email,
  }) async {
    try {
      Map<String, dynamic> param = {
        'email': email,
      };

      final response = await httpService.post(
        endpoint: sendOtpEP,
        params: param,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.data is String) {
          throw ServerException(
              e.response?.data
          );
        }

        print(e.response);
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == 500 &&
            errorMessage == 'User email is not registered.') {
          throw const ServerException('User email is not registered.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      print('RemoteDataSource Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      Map<String, dynamic> params = {
        'email': email,
        'otp': otp,
      };

      final response = await httpService.post(
        endpoint: verifyOtpEP,
        params: params,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.data is String) {
          throw ServerException(
              e.response?.data
          );
        }

        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == HttpStatus.badRequest &&
            errorMessage == 'Email and OTP are required.') {
          throw const ServerException('Email and OTP are required.');
        }

        if (e.response?.statusCode == HttpStatus.badRequest &&
            errorMessage == 'Email is required.') {
          throw const ServerException('Email is required.');
        }

        if (e.response?.statusCode == HttpStatus.badRequest &&
            errorMessage == 'OTP is required.') {
          throw const ServerException('OTP is required.');
        }

        if (e.response?.statusCode == 400 &&
            errorMessage == 'Invalid OTP or OTP expired.') {
          throw const ServerException('Invalid OTP or OTP expired.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      print('RemoteDataSource Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> params = {
        'email': email,
        'password': password,
      };

      final response = await httpService.post(
        endpoint: resetPasswordEP,
        params: params,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw ServerException(e.message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout({
    required String token,
  }) async {
    try {
      Map<String, dynamic> param = {
        'token': token,
      };

      final response = await httpService.post(
        endpoint: bearerLogoutEP,
        params: param,
      );

      if (response.statusCode == 200) {
        await clearToken();
      } else {
        throw ServerException(response.statusMessage.toString());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> storeToken({
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'authToken',
      token,
    );
  }

  @override
  Future<String?> retrieveToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  @override
  Future<UserModel> bearerLogin({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> params = {
        'email': email,
        'password': password,
      };

      final response = await httpService.post(
        endpoint: bearerLoginEP,
        params: params,
      );

      if (response.data == null) {
        throw const ServerException('User not found.');
      }

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        print(responseData);
        final token = responseData['token'];
        // set bearer token
        httpService.updateBearerToken(token);
        print(token);
        print(responseData['user']);
        final userModel = UserModel.fromJson(responseData['user']);
        print(userModel);

        if (userModel.isArchived) {
          throw const ServerException('User account is archived.');
        }

        if (userModel.authStatus == AuthStatus.unauthenticated) {
          throw const ServerException('User is not authenticated.');
        }

        if (userModel.authStatus == AuthStatus.revoked) {
          throw const ServerException('User access is denied.');
        }

        print(token);
        await storeToken(token: token);

        return userModel;
      } else {
        throw ServerException(response.statusMessage.toString());
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.data is String) {
          throw ServerException(
            e.response?.data
          );
        }

        print('err: ${e.response?.data}');
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == HttpStatus.unauthorized &&
            errorMessage == 'Invalid user credential.') {
          throw const ServerException(
            'Invalid user credential.',
          );
        }
        throw ServerException(
          '${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException('${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUserInformation({
    required String id,
    String? profileImage,
    String? password,
  }) async {
    try {
      Map<String, dynamic> queryParam = {
        'user_id': id,
      };

      Map<String, dynamic> param = {
        if (profileImage != null && profileImage.isNotEmpty)
          'profile_image': profileImage,
        if (password != null && password.isNotEmpty) 'password': password,
      };

      final response = await httpService.patch(
        endpoint: updateUserInfoEP,
        queryParams: queryParam,
        params: param,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userModel = UserModel.fromJson(responseData['user']);

        return userModel;
      } else {
        throw ServerException(response.statusMessage.toString());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

// once registered, proceed to log in
// but if acc is unAuth, send an otp to verify first before logging in

// check if email exist, before sending an otp
// send a msg like email is not registered if doesn't exist
