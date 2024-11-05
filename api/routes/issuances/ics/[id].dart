import 'dart:io';

import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
    RequestContext context,
    String id,
    ) async {
  final connection = context.read<Connection>();
  final repository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getIcsInformation(context, repository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getIcsInformation(
    RequestContext context,
    IssuanceRepository repository,
    String id,
    ) async {
  try {
    final ics = await repository.getIcsById(
      id: id,
    );

    if (ics != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'purchase_request': ics.toJson(),
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'ICS request not found.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get ics information: $e',
      },
    );
  }
}
