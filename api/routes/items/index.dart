import 'dart:io';

import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/item/models/item.dart';
import 'package:api/src/item/repository/item_repository.dart';
import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user_activity/user_activity_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);
  final userActivityRepository = UserActivityRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getItems(context, repository),
    HttpMethod.post => _registerItem(
        context,
        connection,
        repository,
        userActivityRepository,
        sessionRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getItems(
  RequestContext context,
  ItemRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final searchQuery = queryParams['search_query']?.trim() ?? '';
    final sortBy = queryParams['sort_by']?.trim();
    final sortAscending =
        bool.tryParse(queryParams['sort_ascending'] ?? 'true') ?? true;

    final filter = queryParams['filter'];

    final manufacturerName = queryParams['manufacturer_name'];
    final brandName = queryParams['brand_name'];
    final assetClassificationString = queryParams['asset_classification'];
    final assetSubClassString = queryParams['asset_sub_class'];

    final assetClassification = assetClassificationString != null
        ? AssetClassification.values.firstWhere(
            (e) => e.toString().split('.').last == assetClassificationString,
            orElse: () => AssetClassification.unknown,
          )
        : null;

    final assetSubClass = assetSubClassString != null
        ? AssetSubClass.values.firstWhere(
            (e) => e.toString().split('.').last == assetSubClassString,
            orElse: () => AssetSubClass.unknown,
          )
        : null;

    final itemList = await repository.getItems(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      sortBy: sortBy,
      sortAscending: sortAscending,
      filter: filter,
      manufacturerName: manufacturerName,
      brandName: brandName,
      classificationFilter: assetClassification,
      subClassFilter: assetSubClass,
    );

    final filteredItemsCount = await repository.getItemsFilteredCount(
      searchQuery: searchQuery,
      filter: filter,
      manufacturerName: manufacturerName,
      brandName: brandName,
      classificationFilter: assetClassification,
      subClassFilter: assetSubClass,
    );

    final suppliesCount = await repository.getSuppliesCount();
    final inventoryCount = await repository.getInventoryItemCount();
    final outOfStockCount = await repository.getOutOfStocksCount();

    final itemJsonList = itemList
        ?.map(
          (item) => item is Supply
              ? item.toJson()
              : item is InventoryItem
                  ? item.toJson()
                  : null,
        )
        .toList();

    return Response.json(
      statusCode: 200,
      body: {
        'total_item_count': filteredItemsCount,
        'supplies_count': suppliesCount,
        'inventory_count': inventoryCount,
        'out_of_stock_count': outOfStockCount,
        'items': itemJsonList,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get items request.',
      },
    );
  }
}

Future<Response> _registerItem(
  RequestContext context,
  Connection connection,
  ItemRepository itemRepository,
  UserActivityRepository userActivityRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;

    // Extract and validate inputs
    final itemType = json['type'] as String?;
    final productName = json['product_name'] as String;
    final description = json['description'] as String?;
    final stockNo = json['stock_no'] as int?;
    final specification = json['specification'] as String?;
    final quantity = json['quantity'] as int;
    final unitCost = json['unit_cost'] as double;

    final manufacturerName = json['manufacturer_name'] as String?;
    final brandName = json['brand_name'] as String?;
    final modelName = json['model_name'] as String?;
    final serialNos = (json['serial_nos'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();

    final estimatedUsefulLife = json['estimated_useful_life'] as int?;
    final acquiredDate = json['acquired_date'] != null
        ? json['acquired_date'] is String
            ? DateTime.parse(json['acquired_date'] as String)
            : json['acquired_date'] as DateTime
        : null;

    FundCluster? fundCluster = json['fund_cluster'] != null
        ? FundCluster.values.firstWhere(
            (e) => e.toString().split('.').last == json['fund_cluster'])
        : null;
    AssetClassification? assetClassification = json['asset_classification'] !=
            null
        ? AssetClassification.values.firstWhere(
            (e) => e.toString().split('.').last == json['asset_classification'])
        : null;
    AssetSubClass? assetSubClass = json['asset_sub_class'] != null
        ? AssetSubClass.values.firstWhere(
            (e) => e.toString().split('.').last == json['asset_sub_class'])
        : null;
    Unit unit = json['unit'] != null
        ? Unit.values
            .firstWhere((e) => e.toString().split('.').last == json['unit'])
        : Unit.undetermined;

    if (itemType == 'inventory' &&
        serialNos != null &&
        serialNos.isNotEmpty &&
        (manufacturerName == null ||
            manufacturerName.isEmpty ||
            brandName == null ||
            brandName.isEmpty ||
            modelName == null ||
            modelName.isEmpty)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'message':
              'Manufacturer, brand, and model are required when a serial no. is provided.'
        },
      );
    }

    // Register product name and description (outside transaction as they're lookup tables)
    int productNameId;
    int productDescriptionId;

    try {
      productNameId = await itemRepository.checkProductNameIfExist(
            productName: productName,
          ) ??
          await itemRepository.registerProductName(
            productName: productName,
          );

      productDescriptionId =
          await itemRepository.checkProductDescriptionIfExist(
                productDescription: description,
              ) ??
              await itemRepository.registerProductDescription(
                productDescription: description,
              );

      // Register product stock if needed
      final productStockResult = await itemRepository.checkProductStockIfExist(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
      );

      if (productStockResult == 0) {
        await itemRepository.registerProductStock(
          productNameId: productNameId,
          productDescriptionId: productDescriptionId,
          stockNo: stockNo,
        );
      }
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'message': 'Error registering product information: $e'},
      );
    }

    // Run the main operation in a transaction
    final response = await connection.runTx((ctx) async {
      try {
        if (itemType == 'inventory') {
          final List<Map<String, dynamic>> registeredItems = [];

          // If serial numbers provided, register one item per serial number
          if (serialNos != null && serialNos.isNotEmpty) {
            for (final serialNo in serialNos) {
              try {
                final baseItemModelId = await itemRepository.registerBaseItem(
                  ctx: ctx,
                  fundCluster: fundCluster,
                  productName: productName,
                  productNameId: productNameId,
                  productDescriptionId: productDescriptionId,
                  specification: specification,
                  unit: unit,
                  quantity: 1,
                  unitCost: unitCost,
                  acquiredDate: acquiredDate,
                );

                final baseItemId = await itemRepository.registerInventoryItem(
                  ctx: ctx,
                  baseItemModelId: baseItemModelId,
                  productNameId: productNameId,
                  manufacturerName: manufacturerName,
                  brandName: brandName,
                  modelName: modelName,
                  serialNo: serialNo,
                  assetClassification: assetClassification,
                  assetSubClass: assetSubClass,
                  estimatedUsefulLife: estimatedUsefulLife,
                );

                final inventoryItem =
                    await itemRepository.getConcreteItemByBaseItemId(
                  ctx: ctx,
                  baseItemId: baseItemId,
                );

                await itemRepository.registerInventoryActivity(
                  ctx: ctx,
                  baseItemId: baseItemId,
                  action: InventoryActivity.added,
                  quantity: 1,
                );

                if (inventoryItem != null) {
                  registeredItems
                      .add((inventoryItem as InventoryItem).toJson());
                }
              } catch (e) {
                if (e.toString().contains(
                    'duplicate key value violates unique constraint')) {
                  return Response.json(
                    statusCode: HttpStatus.conflict,
                    body: {'message': 'Duplicate serial number: $serialNo'},
                  );
                }
                rethrow;
              }
            }
          } else {
            // No serial numbers, register multiple items
            for (int i = 0; i < quantity; i++) {
              final baseItemModelId = await itemRepository.registerBaseItem(
                ctx: ctx,
                fundCluster: fundCluster,
                productName: productName,
                productNameId: productNameId,
                productDescriptionId: productDescriptionId,
                specification: specification,
                unit: unit,
                quantity: 1,
                unitCost: unitCost,
                acquiredDate: acquiredDate,
              );

              final baseItemId = await itemRepository.registerInventoryItem(
                ctx: ctx,
                baseItemModelId: baseItemModelId,
                productNameId: productNameId,
                manufacturerName: manufacturerName,
                brandName: brandName,
                modelName: modelName,
                serialNo: null,
                assetClassification: assetClassification,
                assetSubClass: assetSubClass,
                estimatedUsefulLife: estimatedUsefulLife,
              );

              final item = await itemRepository.getConcreteItemByBaseItemId(
                ctx: ctx,
                baseItemId: baseItemId,
              );

              await itemRepository.registerInventoryActivity(
                ctx: ctx,
                baseItemId: baseItemId,
                action: InventoryActivity.added,
                quantity: 1,
              );

              if (item != null) {
                registeredItems.add((item as InventoryItem).toJson());
              }
            }
          }

          return Response.json(
            statusCode: HttpStatus.ok,
            body: {'items': registeredItems},
          );
        } else if (itemType == 'supply') {
          String? baseItemId;

          final supplyItemResult = await itemRepository.checkSupplyIfExist(
            ctx: ctx,
            productNameId: productNameId,
            productDescriptionId: productDescriptionId,
            specification: specification,
            unit: unit,
            unitCost: unitCost,
            acquiredDate: acquiredDate,
            fundCluster: fundCluster,
          );

          if (supplyItemResult != null) {
            baseItemId = supplyItemResult;
            await itemRepository.updateSupplyItemQuantityByBaseItemId(
              ctx: ctx,
              baseItemId: baseItemId,
              quantity: quantity,
            );
          } else {
            baseItemId = await itemRepository.registerBaseItem(
              ctx: ctx,
              fundCluster: fundCluster,
              productName: productName,
              productNameId: productNameId,
              productDescriptionId: productDescriptionId,
              specification: specification,
              unit: unit,
              quantity: quantity,
              unitCost: unitCost,
              acquiredDate: acquiredDate,
            );

            await itemRepository.registerSupply(
              ctx: ctx,
              baseItemModelId: baseItemId,
            );
          }

          final supplyItem = await itemRepository.getConcreteItemByBaseItemId(
            ctx: ctx,
            baseItemId: baseItemId,
          );

          await itemRepository.registerInventoryActivity(
            ctx: ctx,
            baseItemId: baseItemId,
            action: InventoryActivity.added,
            quantity: quantity,
          );

          return Response.json(
            statusCode: HttpStatus.ok,
            body: {'item': (supplyItem as Supply).toJson()},
          );
        } else {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {'message': 'Invalid or missing item type.'},
          );
        }
      } catch (e) {
        await ctx.rollback();
        rethrow;
      }
    });

    return response;
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': e.toString().contains('Serial no.')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Unexpected error: ${e.toString()}',
      },
    );
  }
}
