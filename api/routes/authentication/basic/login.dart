import 'dart:io';

import 'package:api/src/user/models/user.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = UserRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _authenticateUser(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _authenticateUser(
  RequestContext context,
  UserRepository userRepository,
) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final email = json['email'] as String;
  final password = json['password'] as String;

  final user = await userRepository.checkUserCredentialFromDatabase(
    email: email,
    password: password,
  );

  if (user == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'message': 'Invalid user credential.'},
    );
  } else {
    final Map<String, dynamic>? userJson = user is SupplyDepartmentEmployee
        ? user.toJson()
        : user is MobileUser
            ? user.toJson()
            : null;

    return Response.json(
      body: {
        'user': userJson,
      },
    );
  }
}
