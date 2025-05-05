import 'dart:io';

import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/organization_management/repositories/position_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final officeRepository = OfficeRepository(connection);
  final positionRepository = PositionRepository(connection);
  final officerRepository = OfficerRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getOfficerId(
        context, officeRepository, positionRepository, officerRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getOfficerId(
  RequestContext context,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
  OfficerRepository officerRepository,
) async {
  final queryParams = context.request.uri.queryParameters;
  final officeName = queryParams['office'];
  final positionName = queryParams['position'];
  final officerName = queryParams['name'];

  // Check for missing parameters
  if (officeName == null || positionName == null || officerName == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Missing required query parameters.'},
    );
  }

  final officeId = await officeRepository.checkOfficeIfExist(
    officeName: officeName,
  );

  final positionId = await positionRepository.checkIfPositionExist(
    officeId: officeId,
    positionName: positionName,
  );

  final officerId = await officerRepository.getOfficerId(
    positionId: positionId,
    name: officerName,
  );

  if (officerId == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'error': 'Officer not found.',
      },
    );
  }

  return Response.json(body: {
    'officer_id': officerId,
  });
}
