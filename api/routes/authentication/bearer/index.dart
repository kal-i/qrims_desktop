import 'dart:io';

import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/user.dart';
import 'package:api/src/user/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _createUser(context, userRepository),
    HttpMethod.get =>
      _authenticateUser(context, userRepository, sessionRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _createUser(
  RequestContext context,
  UserRepository repository,
) async {
  try {
    /// Extract whatever is passed on the body and convert it to map
    final json = await context.request.json() as Map<String, dynamic>;

    /// Extract each value from the map
    final name = json['name'] as String;
    final email = json['email'] as String;
    final password = json['password'] as String;
    final createdAt = DateTime.now();
    final role = json['role'] != null
        ? Role.values.firstWhere((e) => e.toString() == 'Role.${json['role']}')
        : null;

    final user = await repository.createUser(
      name: name,
      email: email,
      password: password,
      createdAt: createdAt,
      role: role,
    );

    if (user == null) {
      return Response.json(
        statusCode: 500,
        body: {
          'message': 'Error creating user',
        },
      );
    }

    Map<String, dynamic> userJson;
    if (user is SupplyDepartmentEmployee) {
      userJson = user.toJson();
    } else if (user is MobileUser) {
      userJson = user.toJson();
    } else {
      throw Exception('Unsupported user type.');
    }

    return Response.json(
      body: {
        'message': 'A user was added.',
        'user': userJson,
      },
    );
  } catch (e) {
    print('Error in _createUser: $e');
    return Response.json(
      statusCode: 500,
      body: {
        'message': 'Error processing the create user request',
      },
    );
  }
}

/// Equivalent to logging in in the client side
/// we're getting a token by passing a user cred
Future<Response> _authenticateUser(
  RequestContext context,
  UserRepository userRepository,
  SessionRepository sessionRepository,
) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final email = json['email'] as String;
  final password = json['password'] as String;

  final user = await userRepository.checkUserCredentialFromDatabase(
    email: email,
    password: password,
  );

  if (user == null) {
    return Response.json(statusCode: HttpStatus.unauthorized);
  } else {
    final userId = user is SupplyDepartmentEmployee ? user.id : user is MobileUser ? user.id : null;

    final session = await sessionRepository.createSession(userId!);
    return Response.json(
      body: {
        'token': session.token,
      },
    );
  }
}