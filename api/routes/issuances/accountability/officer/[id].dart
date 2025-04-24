import 'dart:io';

import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final issuanceRepository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getAccountability(
        context,
        issuanceRepository,
        id,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getAccountability(
  RequestContext context,
  IssuanceRepository issuanceRepository,
  String id,
) async {
  try {
    final accountability = await issuanceRepository.getOfficerAccountability(
      officerId: id,
    );

    return Response.json(
      statusCode: 200,
      body: accountability,
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Internal server error',
        'error': e.toString(),
      },
    );
  }
}
