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
    final sortBy = queryParams['sort_by']?.trim() ?? 'acquired_date';
    final sortAscending =
        bool.tryParse(queryParams['sort_ascending'] ?? 'false') ?? false;

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

    print(page);
    print(pageSize);
    print(searchQuery);
    print(sortBy);
    print(sortAscending);
    print(assetClassification);
    print(assetSubClass);

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
    final equipmentCount = await repository.getEquipmentCount();
    final outOfStockCount = await repository.getOutOfStocksCount();

    final itemJsonList = itemList
        ?.map(
          (item) => item is Supply
              ? item.toJson()
              : item is Equipment
                  ? item.toJson()
                  : null,
        )
        .toList();

    return Response.json(
      statusCode: 200,
      body: {
        'total_item_count': filteredItemsCount,
        'supplies_count': suppliesCount,
        'equipment_count': equipmentCount,
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
  ItemRepository itemRepository,
  UserActivityRepository userActivityRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final headers = context.request.headers;
    final json = await context.request.json() as Map<String, dynamic>;

    // get user (the one performing this ope) through the bearer token passed
    // based on that, then we will check if they are authorized to perform the ope
    // if it is, record as well in act db
    // final bearerToken = headers['Authorization']?.substring(7) as String;
    // final session = await sessionRepository.sessionFromToken(bearerToken);
    // final responsibleUserId = session!.userId;

    // Extract and validate inputs
    final productName = json['product_name'] as String;
    final description = json['description'] as String?;
    final specification = json['specification'] as String?;
    final quantity = json['quantity'] as int;
    final unitCost = json['unit_cost'] as double;

    final manufacturerName = json['manufacturer_name'] as String?;
    final brandName = json['brand_name'] as String?;
    final modelName = json['model_name'] as String?;
    final serialNoInput = json['serial_no'] as String?;

    final estimatedUsefulLife = json['estimated_useful_life'] as int?;
    final acquiredDate = json['acquired_date'] != null
        ? json['acquired_date'] is String
            ? DateTime.parse(json['acquired_date'] as String)
            : json['acquired_date'] as DateTime
        : DateTime.now();

    FundCluster? fundCluster;
    AssetClassification? assetClassification;
    AssetSubClass? assetSubClass;
    Unit? unit;

    try {
      fundCluster = json['fund_cluster'] != null
          ? FundCluster.values.firstWhere(
              (e) => e.toString().split('.').last == json['fund_cluster'])
          : null;
      assetClassification = json['asset_classification'] != null
          ? AssetClassification.values.firstWhere((e) =>
              e.toString().split('.').last == json['asset_classification'])
          : AssetClassification.unknown;

      assetSubClass = json['asset_sub_class'] != null
          ? AssetSubClass.values.firstWhere(
              (e) => e.toString().split('.').last == json['asset_sub_class'])
          : AssetSubClass.unknown;

      unit = json['unit'] != null
          ? Unit.values
              .firstWhere((e) => e.toString().split('.').last == json['unit'])
          : Unit.undetermined;
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'message': 'Invalid asset classification, sub class, or unit.',
        },
      );
    }

    int? productNameId;
    int? productDescriptionId;

    final productNameResult = await itemRepository.checkProductNameIfExist(
      productName: productName,
    );

    if (productNameResult != null) {
      productNameId = productNameResult;
    } else {
      productNameId = await itemRepository.registerProductName(
        productName: productName,
      );
    }

    final productDescriptionResult =
        await itemRepository.checkProductDescriptionIfExist(
      productDescription: description,
    );

    if (productDescriptionResult != null) {
      productDescriptionId = productDescriptionResult;
    } else {
      productDescriptionId = await itemRepository.registerProductDescription(
        productDescription: description,
      );
    }
    print('product name id: $productDescriptionId');

    final productStockResult = await itemRepository.checkProductStockIfExist(
      productNameId: productNameId,
      productDescriptionId: productDescriptionId,
    );

    if (productStockResult == 0) {
      await itemRepository.registerProductStock(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
      );
    }

    if ((manufacturerName != null && manufacturerName.isNotEmpty) &&
        (brandName != null && brandName.isNotEmpty) &&
        (modelName != null && modelName.isNotEmpty) &&
        (serialNoInput != null && serialNoInput.isNotEmpty) &&
        (estimatedUsefulLife != null)) {
      // Split the serial number input if provided
      final serialNos =
          serialNoInput.split(' - ').map((s) => s.trim()).toList() ?? [];

      // Register each item separately
      // Each serial number corresponds to a single item
      final List<Map<String, dynamic>> registeredItems = [];

      for (final serialNo in serialNos) {
        try {
          /// register base item model
          final baseItemModelId = await itemRepository.registerBaseItem(
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

          final baseItemId = await itemRepository.registerEquipment(
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

          final equipmentItem =
              await itemRepository.getConcreteItemByBaseItemId(
            baseItemId: baseItemId,
          );

          await itemRepository.registerInventoryActivity(
            baseItemId: baseItemId,
            action: InventoryActivity.added,
            quantity: quantity,
          );

          if (equipmentItem != null) {
            registeredItems.add(
              (equipmentItem as Equipment).toJson(),
            );

            // await userActivityRepository.logUserActivity(
            //   userId: responsibleUserId,
            //   description:
            //       'Registered item with a tracking id of ${item.item.id}.',
            //   actionType: Action.create,
            //   targetId: item.item.id,
            // );
          }
        } catch (e) {
          if (e.toString().contains('Serial no. already exists.')) {
            return Response.json(
              statusCode: HttpStatus.conflict,
              body: {
                'message': 'Duplicate serial number: $serialNo.',
              },
            );
          }
          rethrow;
        }
      }

      return Response.json(
        statusCode: 200,
        body: {
          'items': registeredItems,
        },
      );
    } else {
      /// check first if the supply item already exist
      final supplyItemResult = await itemRepository.checkSupplyIfExist(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
        specification: specification,
        unit: unit,
        unitCost: unitCost,
        acquiredDate: acquiredDate,
      );
      String? baseItemId;

      if (supplyItemResult != null) {
        print('Supply item checked result is not null');
        baseItemId = supplyItemResult;
        await itemRepository.updateSupplyItemQuantityByBaseItemId(
          baseItemId: baseItemId,
          quantity: quantity,
        );
      } else {
        print('Supply item checked is null');
        baseItemId = await itemRepository.registerBaseItem(
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
          baseItemModelId: baseItemId,
        );

        // await itemRepository.generateBatchItems(
        //   acquiredDate: acquiredDate,
        //   baseItemId: baseItemId,
        //   productName: productName,
        //   quantity: quantity,
        //   fundCluster: fundCluster,
        // );
      }

      final supplyItem = await itemRepository.getConcreteItemByBaseItemId(
        baseItemId: baseItemId,
      );

      await itemRepository.registerInventoryActivity(
        baseItemId: baseItemId,
        action: InventoryActivity.added,
        quantity: quantity,
      );

      return Response.json(
        statusCode: 200,
        body: {
          'item': (supplyItem as Supply).toJson(),
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'message': 'Error registering item(s): $e.',
      },
    );
  }
}

// Future<Response> _registerItem(
//   RequestContext context,
//   ItemRepository itemRepository,
//   UserActivityRepository userActivityRepository,
//   SessionRepository sessionRepository,
// ) async {
//   try {
//     final headers = context.request.headers;
//     final json = await context.request.json() as Map<String, dynamic>;

//     // get user (the one performing this ope) through the bearer token passed
//     // based on that, then we will check if they are authorized to perform the ope
//     // if it is, record as well in act db
//     // final bearerToken = headers['Authorization']?.substring(7) as String;
//     // final session = await sessionRepository.sessionFromToken(bearerToken);
//     // final responsibleUserId = session!.userId;

//     // Extract and validate inputs
//     final productName = json['product_name'] as String;
//     final description = json['description'] as String?;
//     final manufacturerName = json['manufacturer_name'] as String;
//     final brandName = json['brand_name'] as String;
//     final modelName = json['model_name'] as String;
//     final serialNoInput = json['serial_no'] as String?;
//     final specification = json['specification'] as String;

//     AssetClassification? assetClassification;
//     AssetSubClass? assetSubClass;
//     Unit? unit;

//     try {
//       assetClassification = json['asset_classification'] != null
//           ? AssetClassification.values.firstWhere((e) =>
//               e.toString().split('.').last == json['asset_classification'])
//           : AssetClassification.unknown;

//       assetSubClass = json['asset_sub_class'] != null
//           ? AssetSubClass.values.firstWhere(
//               (e) => e.toString().split('.').last == json['asset_sub_class'])
//           : AssetSubClass.unknown;

//       unit = json['unit'] != null
//           ? Unit.values
//               .firstWhere((e) => e.toString().split('.').last == json['unit'])
//           : Unit.undetermined;
//     } catch (e) {
//       return Response.json(
//         statusCode: HttpStatus.badRequest,
//         body: {
//           'message': 'Invalid asset classification, sub class, or unit.',
//         },
//       );
//     }

//     final quantity = json['quantity'] as int;
//     final unitCost = json['unit_cost'] as double;
//     final estimatedUsefulLife = json['estimated_useful_life'] as int?;
//     final acquiredDate = json['acquired_date'] is String
//         ? DateTime.parse(json['acquired_date'] as String)
//         : json['acquired_date'] as DateTime?;

//     // Split the serial number input if provided
//     final serialNos =
//         serialNoInput?.split(' - ').map((s) => s.trim()).toList() ?? [];

//     if (serialNos.isEmpty) {
//       return Response.json(
//         statusCode: HttpStatus.badRequest,
//         body: {
//           'message': 'At least one serial number must be provided.',
//         },
//       );
//     }

//     // Register each item separately
//     final List<Map<String, dynamic>> registeredItems = [];

//     for (final serialNo in serialNos) {
//       try {
//         final encryptedItemId = await itemRepository.registerItemWithStock(
//           productName: productName,
//           description: description,
//           manufacturerName: manufacturerName,
//           brandName: brandName,
//           modelName: modelName,
//           serialNo: serialNo,
//           specification: specification,
//           assetClassification: assetClassification,
//           assetSubClass: assetSubClass,
//           unit: unit,
//           quantity: 1, // Each serial number corresponds to a single item
//           unitCost: unitCost,
//           estimatedUsefulLife: estimatedUsefulLife,
//           acquiredDate: acquiredDate,
//         );

//         final item = await itemRepository.getItemByEncryptedId(
//           encryptedId: encryptedItemId,
//         );

//         if (item != null) {
//           registeredItems.add(item.toJson());

//           // await userActivityRepository.logUserActivity(
//           //   userId: responsibleUserId,
//           //   description:
//           //       'Registered item with a tracking id of ${item.item.id}.',
//           //   actionType: Action.create,
//           //   targetId: item.item.id,
//           // );
//         }
//       } catch (e) {
//         if (e.toString().contains('Serial no. already exists.')) {
//           return Response.json(
//             statusCode: HttpStatus.conflict,
//             body: {
//               'message': 'Duplicate serial number: $serialNo.',
//             },
//           );
//         }
//         rethrow;
//       }
//     }

//     return Response.json(
//       statusCode: 200,
//       body: {
//         'items': registeredItems,
//       },
//     );
//   } catch (e) {
//     return Response.json(
//       statusCode: 500,
//       body: {
//         'message': 'Error registering item(s): $e.',
//       },
//     );
//   }
// }

// Future<Response> _registerItem(
//   RequestContext context,
//   ItemRepository itemRepository,
// ) async {
//   try {
//     //final headers = await context.request.headers;
//     //final bearerToken = headers['Authorization']?.substring(7) as String;
//     final json = await context.request.json() as Map<String, dynamic>;
//
//     final productName = json['product_name'] as String;
//     final description = json['description'] as String?;
//     final manufacturerName = json['manufacturer_name'] as String;
//     final brandName = json['brand_name'] as String;
//     final modelName = json['model_name'] as String;
//     final serialNo = json['serial_no'] as String?;
//     final specification = json['specification'] as String;
//
//     AssetClassification? assetClassification;
//     AssetSubClass? assetSubClass;
//     Unit? unit;
//
//     try {
//       // if not null, we'll iterate through each elem in the enums to check if
//       // matches the query params
//       assetClassification = json['asset_classification'] != null
//           ? AssetClassification.values.firstWhere((e) =>
//               e.toString().split('.').last == json['asset_classification'])
//           : AssetClassification.unknown;
//
//       assetSubClass = json['asset_sub_class'] != null
//           ? AssetSubClass.values.firstWhere(
//               (e) => e.toString().split('.').last == json['asset_sub_class'])
//           : AssetSubClass.unknown;
//
//       unit = json['unit'] != null
//           ? Unit.values
//               .firstWhere((e) => e.toString().split('.').last == json['unit'])
//           : Unit.undetermined;
//     } catch (e) {
//       return Response.json(
//         statusCode: HttpStatus.badRequest,
//         body: {
//           'message': 'Invalid asset classification or sub class.',
//         },
//       );
//     }
//
//     final quantity = json['quantity'] as int;
//     final unitCost = json['unit_cost'] as double;
//     final estimatedUsefulLife = json['estimated_useful_life'] as int;
//     final acquiredDate = json['acquired_date'] is String
//         ? DateTime.parse(json['acquired_date'] as String)
//         : json['acquired_date'] as DateTime;
//
//     print(
//       '''
//       $productName
//       $description
//       $manufacturerName
//       $brandName
//       $modelName
//       $serialNo
//       $specification
//       $assetClassification
//       $assetSubClass
//       $unit
//       $quantity
//       $unitCost
//       $estimatedUsefulLife
//       $acquiredDate
//       '''
//     );
//
//     final encryptedItemId = await itemRepository.registerItemWithStock(
//       productName: productName,
//       description: description,
//       manufacturerName: manufacturerName,
//       brandName: brandName,
//       modelName: modelName,
//       serialNo: serialNo,
//       specification: specification,
//       assetClassification: assetClassification,
//       assetSubClass: assetSubClass,
//       unit: unit,
//       quantity: quantity,
//       unitCost: unitCost,
//       estimatedUsefulLife: estimatedUsefulLife,
//       acquiredDate: acquiredDate,
//     );
//
//     final item = await itemRepository.getItemByEncryptedId(
//       encryptedId: encryptedItemId,
//     );
//
//     print(item);
//
//     return Response.json(
//       statusCode: 200,
//       body: {
//         'item': item?.toJson(),
//       },
//     );
//   } catch (e) {
//     return Response.json(statusCode: 500, body: {
//       'message': e.toString().contains('Serial no. already exists.')
//           ? 'Serial no. already exists.'
//           : 'Error registering item(s): $e.',
//     });
//   }
// }
