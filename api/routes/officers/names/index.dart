import 'dart:io';

import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/organization_management/repositories/position_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import 'package:api/src/organization_management/repositories/office_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final officeRepository = OfficeRepository(connection);
  final positionRepository = PositionRepository(connection);
  final officerRepository = OfficerRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getOfficers(
        context, officeRepository, positionRepository, officerRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getOfficers(
  RequestContext context,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
  OfficerRepository officerRepository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final officeName = queryParams['office_name'] as String;
    final positionName = queryParams['position_name'] as String;
    final officerName = queryParams['officer_name'];

    final officeId = await officeRepository.checkOfficeIfExist(
      officeName: officeName,
    );

    final positionId = await positionRepository.checkIfPositionExist(
      officeId: officeId,
      positionName: positionName,
    );

    final officers = await officerRepository.getOfficerNames(
      page: page,
      pageSize: pageSize,
      positionId: positionId,
      officerName: officerName,
    );

    final officerCount = await officerRepository.getOfficerNamesFilteredCount(
      positionId: positionId,
      officerName: officerName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': officerCount,
        'officers': officers,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get officer names request. $e',
      },
    );
  }
}
