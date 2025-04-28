import 'dart:io';

import 'package:api/src/organization_management/models/officer.dart';
import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/organization_management/repositories/position_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final officeRepository = OfficeRepository(connection);
  final positionRepository = PositionRepository(connection);
  final officerRepository = OfficerRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getPositionInformation(
        context,
        officerRepository,
        id,
      ),
    HttpMethod.patch => _updatePositionInformation(
        context,
        officeRepository,
        positionRepository,
        officerRepository,
        id,
      ),
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
      officerId: id,
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
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
  OfficerRepository officerRepository,
  String id,
) async {
  try {
    if (id.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Invalid ID format: $id'},
      );
    }

    final json = await context.request.json();
    final office = json['office'] as String?;
    final position = json['position'] as String?;
    final name = json['name'] as String?;

    String? officeId;
    if (office != null && office.isNotEmpty) {
      officeId = await officeRepository.checkOfficeIfExist(
        officeName: office,
      );
    }

    String? positionId;
    if (officeId != null &&
        officeId.isNotEmpty &&
        position != null &&
        position.isNotEmpty) {
      positionId = await positionRepository.checkIfPositionExist(
        officeId: officeId,
        positionName: position,
      );
    }

    final result = await officerRepository.updateOfficerInformation(
      id: id,
      name: name,
      newPositionId: positionId,
      status: json['status'] != null
          ? OfficerStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
              orElse: () {
                throw Exception('Invalid status value: ${json['status']}');
              },
            )
          : null,
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
