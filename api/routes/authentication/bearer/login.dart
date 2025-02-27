import 'dart:io';

import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/models/user.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post =>
      _authenticateUser(context, userRepository, sessionRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _authenticateUser(
  RequestContext context,
  UserRepository userRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final email = json['email'] as String;
    final password = json['password'] as String;

    final user = await userRepository.checkUserCredentialFromDatabase(
      email: email,
      password: password,
    );

    if (user == null) {
      print('null user');
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'message': 'Invalid user credential. Please check your email or password and try again.',
        },
      );
    }

    final Map<String, dynamic>? userJson = user is SupplyDepartmentEmployee
        ? user.toJson()
        : user is MobileUser
            ? user.toJson()
            : null;

    final userId = user.id;

    print('user id: $userId');

    final session = await sessionRepository.createSession(userId);
    return Response.json(
      body: {
        'token': session.token,
        'user': userJson,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing login: $e.',
      },
    );
  }
}
