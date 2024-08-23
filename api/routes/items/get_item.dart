import 'dart:io';

import 'package:api/src/item/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final itemRepository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getItemInformation(context, itemRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getItemInformation(
  RequestContext context,
  ItemRepository itemRepository,
) async {
  try {
    final queryParam = context.request.uri.queryParameters;
    final itemId = int.parse(queryParam['item_id'] as String);
    final item = await itemRepository.getItemById(id: itemId);

    if (item != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'item': item.toJson(),
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'Item not found.',
      },
    );
  } catch (e) {
    return Response.json(
      body: {
        'message': e.toString(),
      },
    );
  }
}
