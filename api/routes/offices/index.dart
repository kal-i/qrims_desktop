import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import 'package:api/src/organization_management/repositories/office_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = OfficeRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getOffices(context, repository),
    HttpMethod.post => _registerOffice(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getOffices(
  RequestContext context,
  OfficeRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final officeName = queryParams['office_name'];

    final offices = await repository.getOffices(
      page: page,
      pageSize: pageSize,
      officeName: officeName,
    );

    final officesCount = await repository.getOfficeFilteredCount(
      officeName: officeName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': officesCount,
        'offices': offices,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get offices request.',
      },
    );
  }
}

Future<Response> _registerOffice(
  RequestContext context,
  OfficeRepository repository,
) async {
  try {
    final params = await context.request.json();
    final officeName = params['office_name'] as String;

    final officeId = await repository.checkOfficeIfExist(
      officeName: officeName,
    );

    final office = await repository.getOfficeById(
      id: officeId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'office': office?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the register office request. $e',
      },
    );
  }
}
