import 'dart:io';

import 'package:api/src/organization_management/repositories/position_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import 'package:api/src/organization_management/repositories/office_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final officeRepository = OfficeRepository(connection);
  final positionRepository = PositionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get =>
      _getPositions(context, officeRepository, positionRepository),
    HttpMethod.post =>
      _registerPosition(context, officeRepository, positionRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getPositions(
  RequestContext context,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final officeName = queryParams['office_name'] as String;
    final positionName = queryParams['position_name'];

    final officeId = await officeRepository.checkOfficeIfExist(
      officeName: officeName,
    );

    print(officeId);

    final positions = await positionRepository.getPositions(
      page: page,
      pageSize: pageSize,
      officeId: officeId,
      positionName: positionName,
    );

    final positionsCount = await positionRepository.getPositionFilteredCount(
      positionName: positionName,
      officeId: officeId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': positionsCount,
        'positions': positions,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get positions request. $e',
      },
    );
  }
}

Future<Response> _registerPosition(
  RequestContext context,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final params = await context.request.json();

    final officeName = queryParams['office_name'] as String;
    final positionName = params['position_name'] as String;

    final officeId = await officeRepository.checkOfficeIfExist(
      officeName: officeName,
    );
    print(officeId);

    final positionId = await positionRepository.checkIfPositionExist(
      officeId: officeId,
      positionName: positionName,
    );

    final position = await positionRepository.getPositionById(id: positionId);

    return Response.json(
      statusCode: 200,
      body: {
        'position': position?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the register position request. $e',
      },
    );
  }
}
