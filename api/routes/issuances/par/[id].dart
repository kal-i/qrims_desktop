import 'dart:io';

import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
    RequestContext context,
    String id,
    ) async {
  final connection = context.read<Connection>();
  final repository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getParInformation(context, repository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getParInformation(
    RequestContext context,
    IssuanceRepository repository,
    String id,
    ) async {
  try {
    final par = await repository.getParById(
      id: id,
    );

    if (par != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'ics': par.toJson(),
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'PAR request not found.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get par information: $e',
      },
    );
  }
}
