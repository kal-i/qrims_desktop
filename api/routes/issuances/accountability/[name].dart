import 'dart:io';

import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String name,
) async {
  final connection = context.read<Connection>();
  final officerRepository = OfficerRepository(connection);
  final issuanceRepository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getOfficerAccountability(
        context,
        officerRepository,
        issuanceRepository,
        name,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getOfficerAccountability(
  RequestContext context,
  OfficerRepository officerRepository,
  IssuanceRepository issuanceRepository,
  String name,
) async {
  try {
    final decodedName = Uri.decodeComponent(name);

    final accountableOfficer =
        await officerRepository.checkIfAccountableOfficerExist(
      name: decodedName,
    );

    if (!accountableOfficer) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {
          'message': 'Accountable officer not found.',
        },
      );
    }

    final accountability = await issuanceRepository.getOfficerAccountability(
      name: decodedName,
    );

    return Response.json(
      statusCode: 200,
      body: accountability,
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get officer accountability: $e',
      },
    );
  }
}
