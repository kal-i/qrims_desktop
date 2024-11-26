import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final itemRepository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getSummaryInformation(
        context,
        itemRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getSummaryInformation(
  RequestContext context,
  ItemRepository itemRepository,
) async {
  try {
    final inStocksCount = await itemRepository.getInStocksCount();
    final lowStocksCount = await itemRepository.getLowStocksCount();
    final outOfStocksCount = await itemRepository.getOutOfStocksCount();

    final categoricalInventory = await itemRepository.getCategoricalInventory();

    return Response.json(
      body: {
        'in_stocks_count': inStocksCount,
        'low_stocks_count': lowStocksCount,
        'out_of_stocks_count': outOfStocksCount,
        'categorical_inventory_data': categoricalInventory,
      },
    );
  } catch (e) {
    return Response.json(
      body: {
        'message': 'Error processing summary information: $e',
      },
    );
  }
}
