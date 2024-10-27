import 'dart:io';

import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await context.read<Connection>();
  final repository = UserRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getUsers(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getUsers(
    RequestContext context,
    UserRepository repository,
    ) async {
  try {
    final queryParams = context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;

    final users = await repository.getPendingUsers(
      page: page,
      pageSize: pageSize,
    );

    final filteredUserCount = await repository.getPendingUsersFilteredCount();

    return Response.json(
      body: {
        'totalUserCount': filteredUserCount,
        'users': users?.map((user) => user.toJson()).toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get pending users request.',
      },
    );
  }
}