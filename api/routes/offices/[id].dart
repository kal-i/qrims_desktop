import 'dart:io';

import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final repository = OfficeRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getOfficeInformation(context, repository, id),
    HttpMethod.patch => _updateOfficeInformation(context, repository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getOfficeInformation(
  RequestContext context,
  OfficeRepository repository,
  String id,
) async {
  try {
    if (id.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Invalid ID format: $id'},
      );
    }

    final office = await repository.getOfficeById(id: id);

    if (office == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'message': 'Office with an ID of $id is not found.'},
      );
    }

    return Response.json(
      statusCode: 200,
      body: {'office': office.toJson()},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Error retrieving office: $e'},
    );
  }
}

Future<Response> _updateOfficeInformation(
  RequestContext context,
  OfficeRepository repository,
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
    final officeName = params['name'] as String?;

    if (officeName == null || officeName.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Office name cannot be empty.'},
      );
    }

    final result = await repository.updateOfficeInformation(
      id: id,
      officeName: officeName,
    );

    if (result == true) {
      return Response.json(
        statusCode: 200,
        body: {'message': 'Office with ID $id is updated successfully.'},
      );
    }

    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'message': 'Failed to update office with ID $id.'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Error updating office: $e'},
    );
  }
}
