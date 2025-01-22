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
    final suppliesCount = await itemRepository.getSuppliesCount();
    final equipmentCount = await itemRepository.getEquipmentCount();
    final outOfStocksCount = await itemRepository.getOutOfStocksCount();

    final categoricalInventory = await itemRepository.getCategoricalInventory();

    return Response.json(
      body: {
        'supplies_count': suppliesCount,
        'equipment_count': equipmentCount,
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
