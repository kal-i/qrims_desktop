import 'dart:convert';
import 'dart:io';

import 'package:api/src/user/models/user.dart';
import 'package:api/src/user_activity/user_activity.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:api/src/user_activity/user_activity_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final userRepository = UserRepository(connection);
  final userActivityRepository = UserActivityRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch =>
        _updateUserInformation(context, userRepository, userActivityRepository),
    _ => Future.value(Response.json(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _updateUserInformation(
    RequestContext context,
    UserRepository userRepository,
    UserActivityRepository userActivityRepository,
    ) async {
  final queryParams = await context.request.uri.queryParameters;
  final json = await context.request.json() as Map<String, dynamic>;

  final userId = queryParams['user_id'] as String;
  final name = json['name'] as String?;
  final email = json['email'] as String?;
  final password = json['password'] as String?;
  final role = json['role'] != null
      ? Role.values.firstWhere((e) => e.toString() == 'Role.${json['role']}')
      : null;
  final profileImage = json['profile_image'] as String?;

  try {
    final result = await userRepository.updateUserInformation(
      id: userId,
      name: name,
      email: email,
      password: password,
      role: role,
      profileImage: profileImage,
    );

    if (result == false) {

    }

    // Log user activity
    // await userActivit  yRepository.logUserActivity(
    //   userId: userId,
    //   description: 'User $userId updated their information.',
    //   actionType: Action.update,
    // );

    // Return the updated user information
    final updatedUser = await userRepository.getUserInformation(id: userId,);
    final Map<String, dynamic>? userJson = updatedUser is SupplyDepartmentEmployee ? updatedUser.toJson() : updatedUser is MobileUser ? updatedUser.toJson() : null;
    return Response.json(
      statusCode: HttpStatus.ok,
      body: {
        'user': userJson,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'An error occurred: ${e.toString()}'},
    );
  }
}
