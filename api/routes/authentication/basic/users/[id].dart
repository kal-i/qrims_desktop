import 'dart:io';

import 'package:api/src/user/models/user.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = await context.read<Connection>();
  final repository = UserRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getUserInformation(id, repository),
    //HttpMethod.put => _updateUserAuthenticationStatus(id, repository, context), // put for major update
    HttpMethod.patch =>
      _updateUserInformation(id, repository, context), // patch for partial update
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getUserInformation(
  String id,
  UserRepository repository,
) async {
  final user = await repository.getUserInformation(id: id);

  if (user != null) {
    return Response.json(
      body: {
        'user': user is SupplyDepartmentEmployee
            ? user.toJson()
            : user is MobileUser
                ? user.toJson()
                : null,
      },
    );
  }

  return Response.json(
    statusCode: 400,
    body: {'message': 'User not found.'},
  );
}

Future<Response> _updateUserInformation(
  String id,
  UserRepository repository,
  RequestContext context,
) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final name = json['name'] as String?;
  final email = json['email'] as String?;
  final password = json['password'] as String?;
  final role = json['role'] != null
      ? Role.values.firstWhere((e) => e.toString() == 'Role.${json['role']}')
      : null;

  final result = await repository.updateUserInformation(
    id: id,
    name: name,
    email: email,
    password: password,
    role: role,
  );

  if (result == true) {
    return Response.json(
      statusCode: 200,
      body: {
        'message': 'User with an ID of $id is updated successfully.',
      },
    );
  }

  return Response.json(
    statusCode: HttpStatus.internalServerError,
    body: {
      'message': 'Something went wrong while updating user.',
    },
  );
}
