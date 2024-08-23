import 'dart:io';

import 'package:api/src/session/session_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _logoutUser(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _logoutUser(
  RequestContext context,
  SessionRepository repository,
) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final token = json['token'] as String;

  await repository.deleteSession(token);

  return Response.json(
    statusCode: HttpStatus.ok,
    body: {
      'message': 'Logout successful.',
    },
  );
}
