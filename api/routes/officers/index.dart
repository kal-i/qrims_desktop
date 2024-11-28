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
    HttpMethod.get => _getOfficers(context, officerRepository),
    HttpMethod.post => _registerOfficer(
        context, officeRepository, positionRepository, officerRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getOfficers(
  RequestContext context,
  OfficerRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final searchQuery = queryParams['search_query']?.trim() ?? '';
    final sortAscending =
        bool.tryParse(queryParams['sort_ascending'] ?? 'true') ?? true;
    final isArchived = bool.tryParse(queryParams['is_archived'] ?? 'false') ?? false;

    final officers = await repository.getOfficers(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      sortAscending: sortAscending,
      isArchived: isArchived,
    );

    final officersCount = await repository.getOfficersFilteredCount(
      searchQuery: searchQuery,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': officersCount,
        'officers': officers.map((officer) => officer.toJson()).toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get officers request.',
      },
    );
  }
}

Future<Response> _registerOfficer(
  RequestContext context,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
  OfficerRepository officerRepository,
) async {
  try {
    final params = await context.request.json();
    final name = params['name'] as String;
    final officeName = params['office_name'] as String;
    final positionName = params['position_name'] as String;

    final officeId = await officeRepository.checkOfficeIfExist(
      officeName: officeName,
    );

    final positionId = await positionRepository.checkIfPositionExist(
      officeId: officeId,
      positionName: positionName,
    );

    final officerId = await officerRepository.checkOfficerIfExist(
          name: name,
          positionId: positionId,
        ) ??
        await officerRepository.registerOfficer(
          name: name,
          positionId: positionId,
        );

    final officer = await officerRepository.getOfficerById(officerId: officerId,);

    return Response.json(
      statusCode: 200,
      body: {
        'officer': officer?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the register officer request.',
      },
    );
  }
}
