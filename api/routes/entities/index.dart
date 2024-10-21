import 'dart:io';

import 'package:api/src/entity/repository/entity_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = EntityRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getEntities(context, repository),
    HttpMethod.post => _registerEntity(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getEntities(
  RequestContext context,
  EntityRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final entityName = queryParams['entity_name'];

    final entities = await repository.getEntities(
      page: page,
      pageSize: pageSize,
      entityName: entityName,
    );

    final entitiesCount = await repository.getEntitiesFilteredCount(
      entityName: entityName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': entitiesCount,
        'entities': entities,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get entities request.',
      },
    );
  }
}

Future<Response> _registerEntity(
  RequestContext context,
  EntityRepository repository,
) async {
  try {
    final params = await context.request.json();
    final entityName = params['entity_name'] as String;

    String? entityId;

    final entityResult = await repository.checkEntityIfExist(
      entityName: entityName,
    );

    if (entityResult != null) {
      entityId = entityResult;
    } else {
      entityId = await repository.registerEntity(
        entityName: entityName,
      );
    }

    final entity = await repository.getEntityById(
      id: entityId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'entity': entity?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the register entity request. $e',
      },
    );
  }
}
