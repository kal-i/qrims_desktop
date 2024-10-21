import 'dart:io';

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
    HttpMethod.post => _resetPassword(context, userRepository, userActivityRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _resetPassword(
    RequestContext context,
    UserRepository userRepository,
    UserActivityRepository userActivityRepository) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final email = json['email'] as String;
  final password = json['password'] as String;


  final userExist = await userRepository.checkUserIfExist(
    email: email,
  );

  if (!userExist) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'User not found.',
      },
    );
  }

  final result = await userRepository.updateUserPassword(
    email: email,
    password: password,
  );

  if (result == true) {
    // log user act
    // await userActivityRepository.logUserActivity(
    //   userId: user.id,
    //   description: 'User ${user.id} updated their password.',
    //   actionType: Action.update,
    // );

    return Response.json(
      statusCode: 200,
      body: {'message': 'Password updated successfully.'},
    );
  }

  return Response.json(
    statusCode: HttpStatus.internalServerError,
    body: {
      'message': 'Password updated unsuccessful.',
    },
  );
}
