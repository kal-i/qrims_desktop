import 'dart:io';

import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
    RequestContext context,
    String id,
    ) async {
  final connection = context.read<Connection>();
  final repository = OfficerRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getPositionInformation(context, repository, id),
    HttpMethod.patch => _updatePositionInformation(context, repository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getPositionInformation(
    RequestContext context,
    OfficerRepository repository,
    String id,
    ) async {
  try {
    if (id.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Invalid ID format: $id'},
      );
    }

    final officer = await repository.getOfficerById(
      id: id,
    );

    if (officer == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'message': 'Officer with an ID of $id is not found.'},
      );
    }

    return Response.json(
      statusCode: 200,
      body: {'office': officer.toJson()},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Error retrieving officer: $e'},
    );
  }
}

Future<Response> _updatePositionInformation(
    RequestContext context,
    OfficerRepository repository,
    String id,
    ) async {
  try {
    if (id.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Invalid ID format: $id'},
      );
    }

    final params = await context.request.json();
    final name = params['name'] as String?;
    final positionId = params['position_id'] as int?;

    final result = await repository.updateOfficerInformation(
      id: id,
      name: name,
      positionId: id,
    );

    if (result == true) {
      return Response.json(
        statusCode: 200,
        body: {'message': 'Officer with ID $id is updated successfully.'},
      );
    }

    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': 'Failed to update officer with ID $id.'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Error updating officer: $e'},
    );
  }
}
