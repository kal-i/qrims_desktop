import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/utils/encryption_utils.dart';
import 'package:api/src/utils/fund_cluster_value_extension.dart';
import 'package:api/src/utils/generate_id.dart';
import 'package:api/src/utils/qr_code_utils.dart';
import 'package:postgres/postgres.dart';

import '../models/item.dart';

class ItemRepository {
  ItemRepository(this._conn);

  final Connection _conn;

  // Future<String> _generateUniqueProductNameId() async {
  //   while (true) {
  //     final productNameId = generatedId('PRDCTNM');

  //     final result = await _conn.execute(
  //       Sql.named('''
  //       SELECT COUNT(id) FROM ProductNames Where id = @id;
  //       '''),
  //       parameters: {
  //         'id': productNameId,
  //       },
  //     );

  //     final count = result.first[0] as int;

  //     if (count == 0) {
  //       return productNameId;
  //     }
  //   }
  // }

  Future<String> _generateUniqueProductDescriptionId() async {
    while (true) {
      final productDescriptionId = generatedId('PRDCTDSCRPTON');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM ProductDescriptions Where id = @id;
        '''),
        parameters: {
          'id': productDescriptionId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return productDescriptionId;
      }
    }
  }

  Future<String> _generateUniqueItemId(
    String itemName,
    FundCluster? fundCluster,
    DateTime? acquiredDate,
  ) async {
    final now = DateTime.now();

    // Use the provided acquiredDate or the current date
    final yearMonth = acquiredDate != null
        ? "${acquiredDate.year}-${acquiredDate.month.toString().padLeft(2, '0')}"
        : "${now.year}-${now.month.toString().padLeft(2, '0')}";

    // Format the item name: remove spaces and capitalize each word's first letter
    final formattedItemName = itemName
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');

    // Fetch the next value from the sequence for the cumulative count
    final sequenceResult = await _conn.execute(
      Sql.named('SELECT nextval(\'item_id_seq\')'),
    );
    final cumulativeCount = sequenceResult.first[0] as int;

    // Fetch the latest record for the specific item and month
    final itemResult = await _conn.execute(
      Sql.named(
        '''
      SELECT id FROM Items
      WHERE id ILIKE @item_name || '-' || @year_month || '-%'
      ORDER BY id DESC
      LIMIT 1;
      ''',
      ),
      parameters: {
        'item_name': formattedItemName,
        'year_month': yearMonth,
      },
    );

    int itemSpecificCount;
    if (itemResult.isNotEmpty && itemResult.first[0] != null) {
      // Extract the item-specific count from the latest ID for the month
      final latestId = itemResult.first[0].toString();
      final countMatch = RegExp(r'\((\d+)\)$').firstMatch(latestId);
      itemSpecificCount =
          countMatch != null ? int.parse(countMatch.group(1)!) + 1 : 1;
    } else {
      itemSpecificCount = 1;
    }

    // Construct the unique ID with zero-padded cumulative count
    final uniqueId = fundCluster != null
        ? '$formattedItemName-${fundCluster.value}-$yearMonth-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)'
        : '$formattedItemName-$yearMonth-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)';

    return uniqueId;
  }

  // Future<String> _generateUniqueItemId(String itemName) async {
  //   final now = DateTime.now();
  //   final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

  //   // Format the item name: remove spaces and capitalize each word's first letter
  //   final formattedItemName = itemName
  //       .split(' ')
  //       .map((word) => word[0].toUpperCase() + word.substring(1))
  //       .join('');

  //   print('Current year-month: $yearMonth for item: $itemName');

  //   // Start a transaction to ensure atomicity
  //   return await _conn.runTx((ctx) async {
  //     // Step 1: Fetch the latest record for the month to get cumulative count
  //     final monthResult = await ctx.execute(
  //       Sql.named(
  //         '''
  //   SELECT id FROM Items
  //   WHERE id LIKE '%-' || @year_month || '-%'
  //   ORDER BY id DESC
  //   LIMIT 1;
  //   ''',
  //       ),
  //       parameters: {
  //         'year_month': '%$yearMonth%',
  //       },
  //     );
  //     print('month result: ${monthResult}');

  //     int cumulativeCount;
  //     if (monthResult.isNotEmpty) {
  //       final extractedResult =
  //           monthResult.first[0].toString().split('-').last.split('(').first;
  //       print('month result is not empty: ${monthResult.first[0]}');
  //       print('extracted result: $extractedResult');
  //       print('extracted result after + 1: ${int.parse(extractedResult) + 1}');
  //       cumulativeCount = int.parse(monthResult.first[0]
  //               .toString()
  //               .split('-')
  //               .last
  //               .split('(')
  //               .first) +
  //           1;
  //     } else {
  //       cumulativeCount = 1;
  //     }
  //     print('cumulative count: $cumulativeCount');

  //     // Step 2: Fetch the latest record for the specific item this month
  //     final itemResult = await ctx.execute(
  //       Sql.named(
  //         '''
  //   SELECT id FROM Items
  //   WHERE id ILIKE @item_name || '-' || @year_month || '-%'
  //   ORDER BY id DESC
  //   LIMIT 1;
  //   ''',
  //       ),
  //       parameters: {
  //         'item_name': itemName,
  //         'year_month': yearMonth,
  //       },
  //     );
  //     print('item result: $itemResult');

  //     int itemSpecificCount;
  //     if (itemResult.isNotEmpty && itemResult.first[0] != null) {
  //       itemSpecificCount = int.parse(itemResult.first[0]
  //               .toString()
  //               .split('(')
  //               .last
  //               .replaceAll(')', '')) +
  //           1;
  //     } else {
  //       itemSpecificCount = 1;
  //     }
  //     print('item specific count: $itemSpecificCount');

  //     // Construct the unique ID with zero-padded cumulative count
  //     final uniqueId =
  //         '$formattedItemName-$yearMonth-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)';
  //     print('Generated unique ID: $uniqueId');
  //     return uniqueId;
  //   });
  // }

  // Future<String> _generateUniqueItemId(String itemName) async {
  //   final now = DateTime.now();
  //   final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

  //   // Format the item name: remove spaces and capitalize each word's first letter
  //   final formattedItemName = itemName
  //       .split(' ')
  //       .map((word) => word[0].toUpperCase() + word.substring(1))
  //       .join('');

  //   print('Current year-month: $yearMonth for item: $itemName');

  //   // Step 1: Fetch the latest record for the month to get cumulative count
  //   final monthResult = await _conn.execute(
  //     Sql.named(
  //       '''
  //   SELECT id FROM Items
  //   WHERE id LIKE '%-' || @year_month || '-%'
  //   ORDER BY id DESC
  //   LIMIT 1;
  //   ''',
  //     ),
  //     parameters: {
  //       'year_month': '%$yearMonth%',
  //     },
  //   );
  //   print('month result: ${monthResult}');
  //   // we need to extract the

  //   int cumulativeCount;
  //   if (monthResult.isNotEmpty) {
  //     final extractedResult =
  //         monthResult.first[0].toString().split('-').last.split('(').first;
  //     print('month result is not empty: ${monthResult.first[0]}');
  //     print('extracted result: $extractedResult');
  //     print('extracted result after + 1: ${int.parse(extractedResult) + 1}');
  //     cumulativeCount = int.parse(monthResult.first[0]
  //             .toString()
  //             .split('-')
  //             .last
  //             .split('(')
  //             .first) +
  //         1;
  //   } else {
  //     cumulativeCount = 1;
  //   }
  //   print('cumulative count: $cumulativeCount');

  //   // Step 2: Fetch the latest record for the specific item this month
  //   final itemResult = await _conn.execute(
  //     Sql.named(
  //       '''
  //   SELECT id FROM Items
  //   WHERE id ILIKE @item_name || '-' || @year_month || '-%'
  //   ORDER BY id DESC
  //   LIMIT 1;
  //   ''',
  //     ),
  //     parameters: {
  //       'item_name': itemName,
  //       'year_month': yearMonth,
  //     },
  //   );
  //   print('item result: $itemResult');

  //   int itemSpecificCount;
  //   if (itemResult.isNotEmpty && itemResult.first[0] != null) {
  //     itemSpecificCount = int.parse(itemResult.first[0]
  //             .toString()
  //             .split('(')
  //             .last
  //             .replaceAll(')', '')) +
  //         1;
  //   } else {
  //     itemSpecificCount = 1;
  //   }
  //   print('item specific count: $itemSpecificCount');

  //   // Construct the unique ID with zero-padded cumulative count
  //   final uniqueId =
  //       '$formattedItemName-$yearMonth-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)';
  //   print('Generated unique ID: $uniqueId');
  //   return uniqueId;
  // }

  // Future<String> _generateUniqueItemId() async {
  //   while (true) {
  //     final itemId = generatedId('ITM');
  //
  //     final result = await _conn.execute(
  //       Sql.named('''
  //       SELECT COUNT(id) FROM Items Where id = @id;
  //       '''),
  //       parameters: {
  //         'id': itemId,
  //       },
  //     );
  //
  //     final count = result.first[0] as int;
  //
  //     if (count == 0) {
  //       return itemId;
  //     }
  //   }
  // }

  Future<String> _generateUniqueManufacturerId() async {
    while (true) {
      final manufacturerId = generatedId('MNFCTR');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Manufacturers Where id = @id;
        '''),
        parameters: {
          'id': manufacturerId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return manufacturerId;
      }
    }
  }

  Future<String> _generateUniqueBrandId() async {
    while (true) {
      final brandId = generatedId('BRND');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Brands Where id = @id;
        '''),
        parameters: {
          'id': brandId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return brandId;
      }
    }
  }

  Future<String> _generateUniqueModelId() async {
    while (true) {
      final modelId = generatedId('MDL');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Models Where id = @id;
        '''),
        parameters: {
          'id': modelId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return modelId;
      }
    }
  }

  Future<String> registerItemWithStock({
    FundCluster? fundCluster,
    required String productName,
    String? description,
    required String manufacturerName,
    required String brandName,
    required String modelName,
    String? serialNo,
    required String specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required Unit unit,
    required int quantity,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      /// generate an item id
      final itemId = await _generateUniqueItemId(
        productName,
        fundCluster,
        acquiredDate,
      );
      print('item id: $itemId');

      /// generate encrypted id
      final encryptedId = await EncryptionUtils.encryptId(itemId);
      print('encrypted id: $encryptedId');

      /// generate base 64 String qr code image data
      final qrCodeImageData = await QrCodeUtils.generateQRCode(encryptedId);
      print('qr data id: $qrCodeImageData');

      int? productNameId;
      int? productDescriptionId;
      String? manufacturerId;
      String? brandId;
      String? modelId;

      final productNameResult = await checkProductNameIfExist(
        productName: productName,
      );

      if (productNameResult != null) {
        productNameId = productNameResult;
      } else {
        productNameId = await registerProductName(
          productName: productName,
        );
      }
      print('product name id: $productNameId');

      final productDescriptionResult = await checkProductDescriptionIfExist(
        productDescription: description,
      );

      if (productDescriptionResult != null) {
        productDescriptionId = productDescriptionResult;
      } else {
        productDescriptionId = await registerProductDescription(
          productDescription: description,
        );
      }
      print('product name id: $productDescriptionId');

      final productStockResult = await checkProductStockIfExist(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
      );

      if (productStockResult == 0) {
        await registerProductStock(
          productNameId: productNameId,
          productDescriptionId: productDescriptionId,
        );
      }
      print('saved product stock!');

      /// check if manufacturer exists
      final manufacturerResult = await checkManufacturerIfExist(
        manufacturerName: manufacturerName,
      );

      if (manufacturerResult != null) {
        manufacturerId = manufacturerResult;
      } else {
        manufacturerId = await registerManufacturer(
          manufacturerName: manufacturerName,
        );
      }
      print('manufacturer id: $manufacturerId');

      /// check if brand exists
      final brandResult = await checkBrandIfExist(
        brandName: brandName,
      );
      if (brandResult != null) {
        brandId = brandResult;
      } else {
        brandId = await registerBrand(
          brandName: brandName,
        );
      }
      print('brand id: $brandId');

      final manufacturerBrandResult = await checkManufacturerBrandIfExist(
        manufacturerId: manufacturerId,
        brandId: brandId,
      );

      if (manufacturerBrandResult == 0) {
        await registerManufacturerBrand(
          manufacturerId: manufacturerId,
          brandId: brandId,
        );
      }

      /// check if model exists
      final modelResult = await checkModelIfExist(
        productNameId: productNameId,
        brandId: brandId,
        modelName: modelName,
      );

      if (modelResult != null) {
        modelId = modelResult;
      } else {
        modelId = await registerModel(
          productNameId: productNameId,
          brandId: brandId,
          modelName: modelName,
        );
      }
      print('model id: $modelId');

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Items (
          id, product_name_id, product_description_id, manufacturer_id, brand_id, model_id, serial_no, specification,
          asset_classification, asset_sub_class, unit, quantity,
          unit_cost, estimated_useful_life, acquired_date, encrypted_id,
          qr_code_image_data
        ) VALUES (
          @id, @product_name_id, @product_description_id, @manufacturer_id, @brand_id, @model_id, @serial_no, @specification,
          @asset_classification, @asset_sub_class, @unit, @quantity,
          @unit_cost, @estimated_useful_life, @acquired_date, @encrypted_id,
          @qr_code_image_data
        );
        ''',
        ),
        parameters: {
          'id': itemId,
          'product_name_id': productNameId,
          'product_description_id': productDescriptionId,
          'manufacturer_id': manufacturerId,
          'brand_id': brandId,
          'model_id': modelId,
          'serial_no': serialNo,
          'specification': specification,
          'asset_classification':
              assetClassification.toString().split('.').last,
          'asset_sub_class': assetSubClass.toString().split('.').last,
          'unit': unit.toString().split('.').last,
          'quantity': quantity,
          'unit_cost': unitCost,
          'estimated_useful_life': estimatedUsefulLife,
          'acquired_date': acquiredDate,
          'encrypted_id': encryptedId,
          'qr_code_image_data': qrCodeImageData,
        },
      );

      return encryptedId;
    } catch (e) {
      print(e);
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        print('Serial no. already exists');
        throw Exception('Serial no. already exists.');
      }
      throw Exception('Error registering item: $e');
    }
  }

  Future<String> registerBaseItem({
    FundCluster? fundCluster,
    required String productName,
    required int productNameId,
    int? productDescriptionId,
    String? specification,
    required Unit unit,
    required int quantity,
    required double unitCost,
    DateTime? acquiredDate,
  }) async {
    try {
      /// generate an item id
      final itemId = await _generateUniqueItemId(
        productName,
        fundCluster,
        acquiredDate,
      );
      print('item id: $itemId');

      /// generate encrypted id
      final encryptedId = await EncryptionUtils.encryptId(itemId);
      print('encrypted id: $encryptedId');

      /// generate base 64 String qr code image data
      final qrCodeImageData = await QrCodeUtils.generateQRCode(encryptedId);
      print('qr data id: $qrCodeImageData');

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Items (
          id, product_name_id, product_description_id, specification, unit, 
          quantity, unit_cost, encrypted_id, qr_code_image_data, acquired_date
        ) VALUES (
          @id, @product_name_id, @product_description_id, @specification, @unit,
          @quantity, @unit_cost, @encrypted_id, @qr_code_image_data, @acquired_date
        );
        ''',
        ),
        parameters: {
          'id': itemId,
          'product_name_id': productNameId,
          'product_description_id': productDescriptionId,
          'specification': specification,
          'unit': unit.toString().split('.').last,
          'quantity': quantity,
          'unit_cost': unitCost,
          'encrypted_id': encryptedId,
          'qr_code_image_data': qrCodeImageData,
          'acquired_date': acquiredDate ?? DateTime.now().toIso8601String(),
        },
      );

      print('insertion successful');

      return itemId;
    } catch (e) {
      throw Exception('Error registering base item entity: $e');
    }
  }

  Future<List<String>> generateBatchItems({
    required DateTime acquiredDate,
    required String baseItemId,
    required String productName,
    required int quantity,
    FundCluster? fundCluster,
  }) async {
    if (productName.isEmpty) {
      throw ArgumentError('Product name cannot be empty.');
    }

    // Format the product name (capitalize first letter of each word)
    final formattedItemName = productName
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join('');

    // Generate batch codes
    final batchItemCodes = <String>[];
    final batchInserts = <Map<String, dynamic>>[];

    for (int i = 1; i <= quantity; i++) {
      // Construct the batch code
      final batchCode = fundCluster != null
          ? '$formattedItemName-${acquiredDate.year}(${fundCluster.value})-${acquiredDate.month.toString().padLeft(2, '0')}-${i.toString().padLeft(3, '0')}'
          : '$formattedItemName-${acquiredDate.year}${acquiredDate.month.toString().padLeft(2, '0')}-${i.toString().padLeft(3, '0')}';

      batchItemCodes.add(batchCode);

      // Prepare the insert parameters
      batchInserts.add({
        'base_item_id': baseItemId,
        'batch_code': batchCode,
      });
    }

    // Insert all batch items in a single query
    try {
      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO BatchItems (
          base_item_id, 
          batch_code
        ) VALUES (
          @base_item_id,
          @batch_code
        );
        ''',
        ),
        parameters: batchInserts,
      );
    } catch (e) {
      print('Error inserting batch items: $e');
      rethrow; // Rethrow the exception to handle it at a higher level
    }

    print('Generated batch item codes: $batchItemCodes');
    return batchItemCodes;
  }

  Future<String?> checkSupplyIfExist({
    required int productNameId,
    required int productDescriptionId,
    String? specification,
    required Unit unit,
    required double unitCost,
    DateTime? acquiredDate,
  }) async {
    final baseItemResult = await _conn.execute(
      Sql.named(
        '''
        SELECT 
          id 
        FROM 
          Items 
        WHERE 
          product_name_id = @product_name_id 
        AND 
          product_description_id = @product_description_id
        AND
          (specification IS NULL OR specification ILIKE @specification)
        AND
          unit = @unit
        AND
          unit_cost = @unit_cost
        AND
          acquired_date = @acquired_date
        ''',
      ),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
        'specification': specification,
        'unit': unit.toString().split('.').last,
        'unit_cost': unitCost,
        'acquired_date': acquiredDate,
      },
    );

    if (baseItemResult.isNotEmpty) {
      String baseItemId = baseItemResult.first[0] as String;

      final supplyItemResult = await _conn.execute(
        Sql.named(
          'SELECT base_item_id FROM Supplies WHERE base_item_id ILIKE @base_item_id;',
        ),
        parameters: {
          'base_item_id': baseItemId,
        },
      );

      return supplyItemResult.isNotEmpty
          ? supplyItemResult.first[0] as String
          : null;
    }

    return null;
  }

  Future<bool> updateSupplyItemQuantityByBaseItemId({
    required String baseItemId,
    required int quantity,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        UPDATE Items
        SET quantity = quantity + @quantity
        WHERE id = @base_item_id;
        ''',
      ),
      parameters: {
        'base_item_id': baseItemId,
        'quantity': quantity,
      },
    );

    return result.affectedRows == 1;
  }

  Future<String> registerSupply({
    required String baseItemModelId,
  }) async {
    try {
      await _conn.execute(
        Sql.named(
          '''
          INSERT INTO Supplies (base_item_id) VALUES (@base_item_id);
          ''',
        ),
        parameters: {
          'base_item_id': baseItemModelId,
        },
      );

      return baseItemModelId;
    } catch (e) {
      throw Exception('Error registering supply item: $e');
    }
  }

  Future<String> registerEquipment({
    required String baseItemModelId,
    required int productNameId,
    required String manufacturerName,
    required String brandName,
    required String modelName,
    required String serialNo,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    int? estimatedUsefulLife,
  }) async {
    try {
      String? manufacturerId;
      String? brandId;
      String? modelId;

      /// check if manufacturer exists
      final manufacturerResult = await checkManufacturerIfExist(
        manufacturerName: manufacturerName,
      );

      if (manufacturerResult != null) {
        manufacturerId = manufacturerResult;
      } else {
        manufacturerId = await registerManufacturer(
          manufacturerName: manufacturerName,
        );
      }
      print('manufacturer id: $manufacturerId');

      /// check if brand exists
      final brandResult = await checkBrandIfExist(
        brandName: brandName,
      );
      if (brandResult != null) {
        brandId = brandResult;
      } else {
        brandId = await registerBrand(
          brandName: brandName,
        );
      }
      print('brand id: $brandId');

      final manufacturerBrandResult = await checkManufacturerBrandIfExist(
        manufacturerId: manufacturerId,
        brandId: brandId,
      );

      if (manufacturerBrandResult == 0) {
        await registerManufacturerBrand(
          manufacturerId: manufacturerId,
          brandId: brandId,
        );
      }

      /// check if model exists
      final modelResult = await checkModelIfExist(
        productNameId: productNameId,
        brandId: brandId,
        modelName: modelName,
      );

      if (modelResult != null) {
        modelId = modelResult;
      } else {
        modelId = await registerModel(
          productNameId: productNameId,
          brandId: brandId,
          modelName: modelName,
        );
      }
      print('model id: $modelId');

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Equipment (
          base_item_id, manufacturer_id, brand_id, model_id, serial_no, asset_classification,
          asset_sub_class, estimated_useful_life
        ) VALUES (
          @base_item_id, @manufacturer_id, @brand_id, @model_id, @serial_no, 
          @asset_classification, @asset_sub_class, @estimated_useful_life
        );
        ''',
        ),
        parameters: {
          'base_item_id': baseItemModelId,
          'manufacturer_id': manufacturerId,
          'brand_id': brandId,
          'model_id': modelId,
          'serial_no': serialNo,
          'asset_classification':
              assetClassification.toString().split('.').last,
          'asset_sub_class': assetSubClass.toString().split('.').last,
          'estimated_useful_life': estimatedUsefulLife,
        },
      );

      return baseItemModelId;
    } catch (e) {
      throw Exception('Error registering equipment item: $e');
    }
  }

  Future<String> registerItem({
    FundCluster? fundCluster,
    required String productName,
    String? description,
    required String manufacturerName,
    required String brandName,
    required String modelName,
    String? serialNo,
    required String specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required Unit unit,
    required int quantity,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      /// generate an item id
      final itemId = await _generateUniqueItemId(
        productName,
        fundCluster,
        acquiredDate,
      );
      print('item id: $itemId');

      /// generate encrypted id
      final encryptedId = await EncryptionUtils.encryptId(itemId);
      print('encrypted id: $encryptedId');

      /// generate base 64 String qr code image data
      final qrCodeImageData = await QrCodeUtils.generateQRCode(encryptedId);
      print('qr data id: $qrCodeImageData');

      int? productNameId;
      int? productDescriptionId;
      String? manufacturerId;
      String? brandId;
      String? modelId;

      final productNameResult = await checkProductNameIfExist(
        productName: productName,
      );

      if (productNameResult != null) {
        productNameId = productNameResult;
      } else {
        productNameId = await registerProductName(
          productName: productName,
        );
      }
      print('product name id: $productNameId');

      final productDescriptionResult = await checkProductDescriptionIfExist(
        productDescription: description,
      );

      if (productDescriptionResult != null) {
        productDescriptionId = productDescriptionResult;
      } else {
        productDescriptionId = await registerProductDescription(
          productDescription: description,
        );
      }
      print('product name id: $productDescriptionId');

      final productStockResult = await checkProductStockIfExist(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
      );

      if (productStockResult == 0) {
        await registerProductStock(
          productNameId: productNameId,
          productDescriptionId: productDescriptionId,
        );
      }
      print('saved product stock!');

      /// check if manufacturer exists
      final manufacturerResult = await checkManufacturerIfExist(
        manufacturerName: manufacturerName,
      );

      if (manufacturerResult != null) {
        manufacturerId = manufacturerResult;
      } else {
        manufacturerId = await registerManufacturer(
          manufacturerName: manufacturerName,
        );
      }
      print('manufacturer id: $manufacturerId');

      /// check if brand exists
      final brandResult = await checkBrandIfExist(
        brandName: brandName,
      );
      if (brandResult != null) {
        brandId = brandResult;
      } else {
        brandId = await registerBrand(
          brandName: brandName,
        );
      }
      print('brand id: $brandId');

      final manufacturerBrandResult = await checkManufacturerBrandIfExist(
        manufacturerId: manufacturerId,
        brandId: brandId,
      );

      if (manufacturerBrandResult == 0) {
        await registerManufacturerBrand(
          manufacturerId: manufacturerId,
          brandId: brandId,
        );
      }

      /// check if model exists
      final modelResult = await checkModelIfExist(
        productNameId: productNameId,
        brandId: brandId,
        modelName: modelName,
      );

      if (modelResult != null) {
        modelId = modelResult;
      } else {
        modelId = await registerModel(
          productNameId: productNameId,
          brandId: brandId,
          modelName: modelName,
        );
      }
      print('model id: $modelId');

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Items (
          id, product_name_id, product_description_id, manufacturer_id, brand_id, model_id, serial_no, specification,
          asset_classification, asset_sub_class, unit, quantity,
          unit_cost, estimated_useful_life, acquired_date, encrypted_id,
          qr_code_image_data
        ) VALUES (
          @id, @product_name_id, @product_description_id, @manufacturer_id, @brand_id, @model_id, @serial_no, @specification,
          @asset_classification, @asset_sub_class, @unit, @quantity,
          @unit_cost, @estimated_useful_life, @acquired_date, @encrypted_id,
          @qr_code_image_data
        );
        ''',
        ),
        parameters: {
          'id': itemId,
          'product_name_id': productNameId,
          'product_description_id': productDescriptionId,
          'manufacturer_id': manufacturerId,
          'brand_id': brandId,
          'model_id': modelId,
          'serial_no': serialNo,
          'specification': specification,
          'asset_classification':
              assetClassification.toString().split('.').last,
          'asset_sub_class': assetSubClass.toString().split('.').last,
          'unit': unit.toString().split('.').last,
          'quantity': quantity,
          'unit_cost': unitCost,
          'estimated_useful_life': estimatedUsefulLife,
          'acquired_date': acquiredDate,
          'encrypted_id': encryptedId,
          'qr_code_image_data': qrCodeImageData,
        },
      );

      return encryptedId;
    } catch (e) {
      print(e);
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        print('Serial no. already exists');
        throw Exception('Serial no. already exists.');
      }
      throw Exception('Error registering item: $e');
    }
  }

  // Future<List<String>> registerItemsWithStock({
  //   required String productName,
  //   String? description,
  //   required String manufacturerName,
  //   required String brandName,
  //   required String modelName,
  //   required String serialNo,
  //   required String specification,
  //   AssetClassification? assetClassification,
  //   AssetSubClass? assetSubClass,
  //   required Unit unit,
  //   required int quantity,
  //   required double unitCost,
  //   int? estimatedUsefulLife,
  //   DateTime? acquiredDate,
  // }) async {
  //   try {
  //     // Split the serial numbers by the separator
  //     final serialNumbers = serialNo.split(' - ').map((s) => s.trim()).toList();
  //
  //     List<String> encryptedIds = [];
  //
  //     for (var serial in serialNumbers) {
  //       // Generate a unique item ID for each serial number
  //       final itemId = await _generateUniqueItemId(productName);
  //       print('item id: $itemId');
  //
  //       // Generate encrypted ID
  //       final encryptedId = await EncryptionUtils.encryptId(itemId);
  //       print('encrypted id: $encryptedId');
  //
  //       // Generate QR code image data
  //       final qrCodeImageData = await QrCodeUtils.generateQRCode(encryptedId);
  //       print('qr data id: $qrCodeImageData');
  //
  //       String? productNameId;
  //       String? productDescriptionId;
  //       String? manufacturerId;
  //       String? brandId;
  //       String? modelId;
  //
  //       // Fetch or create product name
  //       final productNameResult = await checkProductNameIfExist(productName: productName);
  //       productNameId = productNameResult ?? await registerProductName(productName: productName);
  //
  //       // Fetch or create product description
  //       final productDescriptionResult = await checkProductDescriptionIfExist(productDescription: description);
  //       productDescriptionId = productDescriptionResult ?? await registerProductDescription(productDescription: description);
  //
  //       // Ensure product stock exists
  //       final productStockResult = await checkProductStockIfExist(
  //         productNameId: productNameId,
  //         productDescriptionId: productDescriptionId,
  //       );
  //       if (productStockResult == 0) {
  //         await registerProductStock(productNameId: productNameId, productDescriptionId: productDescriptionId);
  //       }
  //
  //       // Fetch or create manufacturer
  //       final manufacturerResult = await checkManufacturerIfExist(manufacturerName: manufacturerName);
  //       manufacturerId = manufacturerResult ?? await registerManufacturer(manufacturerName: manufacturerName);
  //
  //       // Fetch or create brand
  //       final brandResult = await checkBrandIfExist(brandName: brandName);
  //       brandId = brandResult ?? await registerBrand(brandName: brandName);
  //
  //       // Ensure manufacturer-brand relationship exists
  //       final manufacturerBrandResult = await checkManufacturerBrandIfExist(
  //         manufacturerId: manufacturerId,
  //         brandId: brandId,
  //       );
  //       if (manufacturerBrandResult == 0) {
  //         await registerManufacturerBrand(manufacturerId: manufacturerId, brandId: brandId);
  //       }
  //
  //       // Fetch or create model
  //       final modelResult = await checkModelIfExist(
  //         productNameId: productNameId,
  //         brandId: brandId,
  //         modelName: modelName,
  //       );
  //       modelId = modelResult ?? await registerModel(
  //         productNameId: productNameId,
  //         brandId: brandId,
  //         modelName: modelName,
  //       );
  //
  //       // Insert item record
  //       await _conn.execute(
  //         Sql.named(
  //           '''
  //         INSERT INTO Items (
  //           id, product_name_id, product_description_id, manufacturer_id, brand_id, model_id, serial_no, specification,
  //           asset_classification, asset_sub_class, unit, quantity,
  //           unit_cost, estimated_useful_life, acquired_date, encrypted_id,
  //           qr_code_image_data
  //         ) VALUES (
  //           @id, @product_name_id, @product_description_id, @manufacturer_id, @brand_id, @model_id, @serial_no, @specification,
  //           @asset_classification, @asset_sub_class, @unit, @quantity,
  //           @unit_cost, @estimated_useful_life, @acquired_date, @encrypted_id,
  //           @qr_code_image_data
  //         );
  //         ''',
  //         ),
  //         parameters: {
  //           'id': itemId,
  //           'product_name_id': productNameId,
  //           'product_description_id': productDescriptionId,
  //           'manufacturer_id': manufacturerId,
  //           'brand_id': brandId,
  //           'model_id': modelId,
  //           'serial_no': serial,
  //           'specification': specification,
  //           'asset_classification': assetClassification?.toString().split('.').last,
  //           'asset_sub_class': assetSubClass?.toString().split('.').last,
  //           'unit': unit.toString().split('.').last,
  //           'quantity': quantity,
  //           'unit_cost': unitCost,
  //           'estimated_useful_life': estimatedUsefulLife,
  //           'acquired_date': acquiredDate,
  //           'encrypted_id': encryptedId,
  //           'qr_code_image_data': qrCodeImageData,
  //         },
  //       );
  //
  //       encryptedIds.add(encryptedId);
  //     }
  //
  //     return encryptedIds; // Return all encrypted IDs for registered items
  //   } catch (e) {
  //     print(e);
  //     if (e.toString().contains('duplicate key value violates unique constraint')) {
  //       print('Serial no. already exists');
  //       throw Exception('Serial no. already exists.');
  //     }
  //     throw Exception('Error registering items: $e');
  //   }
  // }

  Future<int> registerProductName({
    required String productName,
  }) async {
    final result = await _conn.execute(
      Sql.named('''
      INSERT INTO ProductNames (name)
      VALUES (@name)
      RETURNING id
    '''),
      parameters: {
        'name': productName,
      },
    );

    return result.first[0] as int; // Return the generated ID
  }

  Future<int?> checkProductNameIfExist({
    required String productName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
        SELECT id FROM ProductNames WHERE name ILIKE @name;
      '''),
      parameters: {
        'name': productName,
      },
    );

    if (checkIfExists.isEmpty) {
      print('product name result is empty');
      return null;
      //return await registerProductName(productName: productName);
    } else {
      print('product name result is not empty: $checkIfExists');
      return checkIfExists.first[0] as int;
    }
  }

  Future<int> registerProductDescription({
    String? productDescription,
  }) async {
    final result = await _conn.execute(
      Sql.named('''
      INSERT INTO ProductDescriptions (description)
      VALUES (@description)
      RETURNING id
    '''),
      parameters: {
        'description': productDescription,
      },
    );

    return result.first[0] as int; // Return the generated ID
  }

  Future<int?> checkProductDescriptionIfExist({
    String? productDescription,
  }) async {
    final checkIfExists = productDescription == null
        ? await _conn.execute(
            Sql.named('''
          SELECT id FROM ProductDescriptions WHERE description IS NULL;
        '''),
          )
        : await _conn.execute(
            Sql.named('''
          SELECT id FROM ProductDescriptions WHERE description ILIKE @description;
        '''),
            parameters: {
              'description': productDescription,
            },
          );

    if (checkIfExists.isEmpty) {
      print('product desc result is empty');
      return null;
      // return await registerProductDescription(
      //   productDescription: productDescription,
      // );
    } else {
      print('product desc result is not empty: $checkIfExists');
      return checkIfExists.first[0] as int;
    }
  }

  Future<void> registerProductStock({
    required int productNameId,
    required int productDescriptionId,
  }) async {
    await _conn.execute(
      Sql.named('''
      INSERT INTO ProductStocks (product_name_id, product_description_id)
      VALUES (@product_name_id, @product_description_id)
    '''),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
      },
    );
  }

  Future<int> checkProductStockIfExist({
    required int productNameId,
    required int productDescriptionId,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT COUNT(*) FROM ProductStocks WHERE product_name_id = @product_name_id AND product_description_id = @product_description_id;
    '''),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
      },
    );

    return checkIfExists.first[0] as int;
    // final count = checkIfExists.first[0] as int;

    // if (count == 0) {
    //   print('product stock result is empty');
    //   await registerProductStock(
    //     productNameId: productNameId,
    //     productDescriptionId: productDescriptionId,
    //   );
    // } else {
    //   print('product stock result is not empty: $checkIfExists');
    // }
  }

  Future<String> registerManufacturer({
    required String manufacturerName,
  }) async {
    final manufacturerId = await _generateUniqueManufacturerId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO Manufacturers (id, name)
      VALUES (@id, @name)
    '''),
      parameters: {
        'id': manufacturerId,
        'name': manufacturerName,
      },
    );

    return manufacturerId;
  }

  Future<String?> checkManufacturerIfExist({
    required String manufacturerName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
        SELECT id FROM Manufacturers WHERE name ILIKE @name;
      '''),
      parameters: {
        'name': manufacturerName,
      },
    );

    if (checkIfExists.isEmpty) {
      print('manufacturer result is empty');
      return null;
      //return await registerManufacturer(manufacturerName: manufacturerName);
    } else {
      print('manufacturer result is not empty: $checkIfExists');
      return checkIfExists.first[0] as String;
    }
  }

  Future<String> registerBrand({required String brandName}) async {
    final brandId = await _generateUniqueBrandId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO Brands (id, name)
      VALUES (@id, @name)
    '''),
      parameters: {
        'id': brandId,
        'name': brandName,
      },
    );

    return brandId;
  }

  Future<String?> checkBrandIfExist({
    required String brandName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT id FROM Brands WHERE name ILIKE @name;
    '''),
      parameters: {
        'name': brandName,
      },
    );

    if (checkIfExists.isEmpty) {
      print('brand result is empty');
      return null;
      //return await registerBrand(brandName: brandName);
    } else {
      print('brand result is not empty: $checkIfExists');
      return checkIfExists.first[0] as String;
    }
  }

  Future<void> registerManufacturerBrand({
    required String manufacturerId,
    required String brandId,
  }) async {
    await _conn.execute(
      Sql.named('''
      INSERT INTO ManufacturerBrands (manufacturer_id, brand_id)
      VALUES (@manufacturer_id, @brand_id)
    '''),
      parameters: {
        'manufacturer_id': manufacturerId,
        'brand_id': brandId,
      },
    );
  }

  Future<int> checkManufacturerBrandIfExist({
    required String manufacturerId,
    required String brandId,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT COUNT(*) FROM ManufacturerBrands WHERE manufacturer_id = @manufacturer_id AND brand_id = @brand_id;
    '''),
      parameters: {
        'manufacturer_id': manufacturerId,
        'brand_id': brandId,
      },
    );

    return checkIfExists.first[0] as int;
    // final count = checkIfExists.first[0] as int;
    //
    // if (count == 0) {
    //   print('manufacturer brand result is empty');
    //   await registerManufacturerBrand(
    //     manufacturerId: manufacturerId,
    //     brandId: brandId,
    //   );
    // } else {
    //   print('manufacturer brand result is not empty: $checkIfExists');
    // }
  }

  Future<String> registerModel({
    required int productNameId,
    required String brandId,
    required String modelName,
  }) async {
    final modelId = await _generateUniqueModelId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO Models (id, product_name_id, brand_id, model_name)
      VALUES (@id, @product_name_id, @brand_id, @model_name)
    '''),
      parameters: {
        'id': modelId,
        'product_name_id': productNameId,
        'brand_id': brandId,
        'model_name': modelName,
      },
    );

    return modelId;
  }

  Future<String?> checkModelIfExist({
    required int productNameId,
    required String brandId,
    required String modelName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT id FROM Models WHERE product_name_id = @product_name_id AND brand_id = @brand_id AND model_name = @model_name;
    '''),
      parameters: {
        'product_name_id': productNameId,
        'brand_id': brandId,
        'model_name': modelName,
      },
    );

    // ['first'] only to access the id
    if (checkIfExists.isEmpty) {
      print('model result is empty');
      return null;
      // return await registerModel(
      //   productNameId: productNameId,
      //   brandId: brandId,
      //   modelName: modelName,
      // );
    } else {
      print('model result is not empty: ${checkIfExists.first}');
      return checkIfExists.first[0] as String;
    }
  }

  Future<BaseItemModel?> getConcreteItemByBaseItemId({
    required String baseItemId,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT
          i.*,
          pn.name as product_name,
          pd.description as product_description,
          s.id as supply_id,
          e.id as equipment_id,
          e.manufacturer_id,
          e.brand_id,
          e.model_id,
          e.serial_no,
          e.asset_classification,
          e.asset_sub_class,
          e.estimated_useful_life,
          mnf.name as manufacturer_name,
          brnd.name as brand_name,
          md.model_name
        FROM
          Items i
        LEFT JOIN
          ProductNames pn ON i.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON i.product_description_id = pd.id
        LEFT JOIN
          Supplies s ON i.id = s.base_item_id
        LEFT JOIN
          Equipment e ON i.id = e.base_item_id
        LEFT JOIN
          Manufacturers mnf ON e.manufacturer_id =  mnf.id
        LEFT JOIN
          Brands brnd ON e.brand_id = brnd.id
        LEFT JOIN
          Models md ON e.model_id = md.id
        WHERE
          i.id = @base_item_id;
        ''',
      ),
      parameters: {
        'base_item_id': baseItemId,
      },
    );

    final row = result.first;

    if (row[12] != null) {
      final supplyMap = {
        'supply_id': row[12],
        'base_item_id': row[0],
        'product_name_id': row[1],
        'product_description_id': row[2],
        'specification': row[3],
        'unit': row[4],
        'quantity': row[5],
        'encrypted_id': row[6],
        'qr_code_image_data': row[7],
        'unit_cost': row[8],
        'acquired_date': row[9],
        'product_name': row[10],
        'product_description': row[11],
      };
      return Supply.fromJson(supplyMap);
    } else if (row[13] != null) {
      final equipmentMap = {
        'equipment_id': row[13],
        'base_item_id': row[0],
        'product_name_id': row[1],
        'product_description_id': row[2],
        'specification': row[3],
        'unit': row[4],
        'quantity': row[5],
        'encrypted_id': row[6],
        'qr_code_image_data': row[7],
        'unit_cost': row[8],
        'acquired_date': row[9],
        'product_name': row[10],
        'product_description': row[11],
        'manufacturer_id': row[14],
        'brand_id': row[15],
        'model_id': row[16],
        'serial_no': row[17],
        'asset_classification': row[18],
        'asset_sub_class': row[19],
        'estimated_useful_life': row[20],
        'manufacturer_name': row[21],
        'brand_name': row[22],
        'model_name': row[23],
      };
      return Equipment.fromJson(equipmentMap);
    }

    return null;
  }

  Future<ItemWithStock?> getItemByEncryptedId({
    required String encryptedId,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
          SELECT
            i.*,
            pn.name as product_name,
            pd.description as product_description,
            mnf.name as manufacturer_name,
            brnd.name as brand_name,
            md.model_name
          FROM
            Items i
          LEFT JOIN
            ProductNames pn ON i.product_name_id = pn.id
          LEFT JOIN
            ProductDescriptions pd ON i.product_description_id = pd.id
          LEFT JOIN
            Manufacturers mnf ON i.manufacturer_id =  mnf.id
          LEFT JOIN
            Brands brnd ON i.brand_id = brnd.id
          LEFT JOIN
            Models md ON i.model_id = md.id
          WHERE
            i.encrypted_id = @encrypted_id;
          ''',
      ),
      parameters: {
        'encrypted_id': encryptedId,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    final itemWithStockMap = {
      'item_id': row[0],
      'product_name_id': row[1],
      'product_description_id': row[2],
      'manufacturer_id': row[3],
      'brand_id': row[4],
      'model_id': row[5],
      'serial_no': row[6],
      'specification': row[7],
      'asset_classification': row[8],
      'asset_sub_class': row[9],
      'unit': row[10],
      'quantity': row[11],
      'encrypted_id': row[12],
      'qr_code_image_data': row[13],
      'product_name': row[14],
      'product_description': row[15],
      'unit_cost': row[16],
      'estimated_useful_life': row[17],
      'acquired_date': row[18],
      'manufacturer_name': row[19],
      'brand_name': row[20],
      'model_name': row[21],
    };

    return ItemWithStock.fromJson(itemWithStockMap);
  }

  Future<int> getItemsFilteredCount({
    String? searchQuery,
    String? filter,
    String? manufacturerName,
    String? brandName,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  }) async {
    try {
      final params = <String, dynamic>{};
      final baseQuery = '''
        SELECT
          COUNT(i.*)
        FROM
          Items i
        LEFT JOIN
          ProductNames pn ON i.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON i.product_description_id = pd.id
        LEFT JOIN
          Supplies s ON i.id = s.base_item_id
        LEFT JOIN
          Equipment e ON i.id = e.base_item_id
        LEFT JOIN
          Manufacturers mnf ON e.manufacturer_id =  mnf.id
        LEFT JOIN
          Brands brnd ON e.brand_id = brnd.id
        LEFT JOIN
          Models md ON e.model_id = md.id
      ''';

      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
          WHERE pn.name ILIKE @search_query
          ''',
        );

        params['search_query'] = '%$searchQuery%';
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('mnf.name = @manufacturer_name');
        params['manufacturer_name'] = manufacturerName;
      }

      if (brandName != null && brandName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('brnd.name = @brand_name');
        params['brand_name'] = brandName;
      }

      if (classificationFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('e.asset_classification = @classification_filter');
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('e.asset_sub_class = @sub_class_filter');
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND (' : 'WHERE (');
        if (filter == 'supply') {
          whereClause.write('s.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'equipment') {
          whereClause.write('e.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'out') {
          whereClause.write('i.quantity = 0');
        } else {
          whereClause.write(
              '(s.id IS NOT NULL OR e.id IS NOT NULL) AND i.quantity > 0');
        }
        whereClause.write(')');
      }

      final finalQuery = '''
      $baseQuery
      $whereClause
      ''';

      final result = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      if (result.isNotEmpty) {
        final count = result.first[0] as int;
        print('Total no. of filtered items: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching items: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  Future<int> getInStockItemsCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT COUNT(*) FROM Items WHERE quantity > 5;''',
      ),
    );

    return result.first[0] as int;
  }

  Future<int> getLowItemStocksCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT COUNT(*) FROM Items WHERE quantity > 0 AND quantity <= 5;''',
      ),
    );
    return result.first[0] as int;
  }

  Future<int> getOutOfStockItemsCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT COUNT(*)FROM Items WHERE quantity = 0;''',
      ),
    );

    return result.first[0] as int;
  }

  Future<List<BaseItemModel>?> getItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    String sortBy = 'acquired_date',
    bool sortAscending = false,
    String? filter,
    String? manufacturerName,
    String? brandName,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final itemList = <BaseItemModel>[];
      final params = <String, dynamic>{};

      final baseQuery = '''
        SELECT
          i.*,
          pn.name as product_name,
          pd.description as product_description,
          s.id as supply_id,
          e.id as equipment_id,
          e.manufacturer_id,
          e.brand_id,
          e.model_id,
          e.serial_no,
          e.asset_classification,
          e.asset_sub_class,
          e.estimated_useful_life,
          mnf.name as manufacturer_name,
          brnd.name as brand_name,
          md.model_name
        FROM
          Items i
        LEFT JOIN
          ProductNames pn ON i.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON i.product_description_id = pd.id
        LEFT JOIN
          Supplies s ON i.id = s.base_item_id
        LEFT JOIN
          Equipment e ON i.id = e.base_item_id
        LEFT JOIN
          Manufacturers mnf ON e.manufacturer_id =  mnf.id
        LEFT JOIN
          Brands brnd ON e.brand_id = brnd.id
        LEFT JOIN
          Models md ON e.model_id = md.id
      ''';

      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
          WHERE pn.name ILIKE @search_query
          ''',
        );

        params['search_query'] = '%$searchQuery%';
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('mnf.name = @manufacturer_name');
        params['manufacturer_name'] = manufacturerName;
      }

      if (brandName != null && brandName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('brnd.name = @brand_name');
        params['brand_name'] = brandName;
      }

      if (classificationFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('e.asset_classification = @classification_filter');
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('e.asset_sub_class = @sub_class_filter');
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND (' : 'WHERE (');
        if (filter == 'supply') {
          whereClause.write('s.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'equipment') {
          whereClause.write('e.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'out') {
          whereClause.write('i.quantity = 0');
        } else {
          whereClause.write(
              '(s.id IS NOT NULL OR e.id IS NOT NULL) AND i.quantity > 0');
        }
        whereClause.write(')');
      }

      final sortDirection = sortAscending ? 'ASC' : 'DESC';

      final finalQuery = '''
      $baseQuery
      $whereClause
      ORDER BY
        $sortBy $sortDirection
      LIMIT @page_size OFFSET @offset;
      ''';

      params['page_size'] = pageSize;
      params['offset'] = offset;

      print('final query: $finalQuery');
      print('params: $params');

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      print('raw res: $results');

      for (final row in results) {
        if (row[12] != null) {
          final supplyMap = {
            'supply_id': row[12],
            'base_item_id': row[0],
            'product_name_id': row[1],
            'product_description_id': row[2],
            'specification': row[3],
            'unit': row[4],
            'quantity': row[5],
            'encrypted_id': row[6],
            'qr_code_image_data': row[7],
            'unit_cost': row[8],
            'acquired_date': row[9],
            'product_name': row[10],
            'product_description': row[11],
          };
          itemList.add(Supply.fromJson(supplyMap));
        } else if (row[13] != null) {
          final equipmentMap = {
            'equipment_id': row[13],
            'base_item_id': row[0],
            'product_name_id': row[1],
            'product_description_id': row[2],
            'specification': row[3],
            'unit': row[4],
            'quantity': row[5],
            'encrypted_id': row[6],
            'qr_code_image_data': row[7],
            'unit_cost': row[8],
            'acquired_date': row[9],
            'product_name': row[10],
            'product_description': row[11],
            'manufacturer_id': row[14],
            'brand_id': row[15],
            'model_id': row[16],
            'serial_no': row[17],
            'asset_classification': row[18],
            'asset_sub_class': row[19],
            'estimated_useful_life': row[20],
            'manufacturer_name': row[21],
            'brand_name': row[22],
            'model_name': row[23],
          };
          itemList.add(Equipment.fromJson(equipmentMap));
        }
      }
      print('Fetched items for page $page: ${itemList.length}');
      return itemList;
    } catch (e) {
      print('Error fetching items: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  // Future<List<ItemWithStock>?> getItems({
  //   required int page,
  //   required int pageSize,
  //   String? searchQuery,
  //   String sortBy = 'acquired_date',
  //   bool sortAscending = false,
  //   String? filter,
  //   String? manufacturerName,
  //   String? brandName,
  //   // double? minimumUnitPrice,
  //   // double? maximumUnitPrice,
  //   AssetClassification? classificationFilter,
  //   AssetSubClass? subClassFilter,
  //   //DateTime? acquiredDate,
  // }) async {
  //   try {
  //     final offset = (page - 1) * pageSize;
  //     final itemList = <ItemWithStock>[];
  //     final params = <String, dynamic>{};

  //     // working fine
  //     final validSortColumn = {
  //       'quantity',
  //       'unit_cost',
  //       'estimated_useful_life',
  //       'acquired_date'
  //     };

  //     if (!validSortColumn.contains(sortBy)) {
  //       throw ArgumentError('Invalid sort column: $sortBy');
  //     }

  //     final baseQuery = '''
  //     SELECT
  //       i.*,
  //       pn.name as product_name,
  //       pd.description as product_description,
  //       mnf.name as manufacturer_name,
  //       brnd.name as brand_name,
  //       md.model_name
  //     FROM
  //       Items i
  //     LEFT JOIN
  //       ProductNames pn ON i.product_name_id = pn.id
  //     LEFT JOIN
  //       ProductDescriptions pd ON i.product_description_id = pd.id
  //     LEFT JOIN
  //       Manufacturers mnf ON i.manufacturer_id =  mnf.id
  //     LEFT JOIN
  //       Brands brnd ON i.brand_id = brnd.id
  //     LEFT JOIN
  //       Models md ON i.model_id = md.id
  //     ''';

  //     final whereClause = StringBuffer();
  //     // There really is no problem in the search query, except for the fact that it is confuse between id and serial no.
  //     if (searchQuery != null && searchQuery.isNotEmpty) {
  //       whereClause.write(
  //         '''
  //         WHERE pn.name ILIKE @search_query
  //         ''',
  //       );

  //       params['search_query'] = '%$searchQuery%';
  //       // i.id = @search_query OR
  //       // i.serial_no = @search_query
  //       // mnf.name ILIKE @search_query OR
  //       // brnd.name ILIKE @search_query OR
  //       // md.model_name ILIKE @search_query OR
  //       // i.specification ILIKE @search_query
  //     }

  //     if (manufacturerName != null && manufacturerName.isNotEmpty) {
  //       whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
  //       whereClause.write('mnf.name = @manufacturer_name');
  //       params['manufacturer_name'] = manufacturerName;
  //     }

  //     if (brandName != null && brandName.isNotEmpty) {
  //       whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
  //       whereClause.write('brnd.name = @brand_name');
  //       params['brand_name'] = brandName;
  //     }

  //     if (classificationFilter != null) {
  //       whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
  //       whereClause.write('i.asset_classification = @classification_filter');
  //       params['classification_filter'] =
  //           classificationFilter.toString().split('.').last;
  //     }

  //     if (subClassFilter != null) {
  //       whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
  //       whereClause.write('i.asset_sub_class = @sub_class_filter');
  //       params['sub_class_filter'] = subClassFilter.toString().split('.').last;
  //     }

  //     if (filter != null && filter.isNotEmpty) {
  //       whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
  //       if (filter == 'in_stock') {
  //         whereClause.write('i.quantity > 0');
  //       }

  //       if (filter == 'out') {
  //         whereClause.write('i.quantity = 0');
  //       }
  //     }

  //     final sortDirection = sortAscending ? 'ASC' : 'DESC';
  //     print('sort dir: $sortDirection');

  //     final finalQuery = '''
  //     $baseQuery
  //     $whereClause
  //     ORDER BY
  //       $sortBy $sortDirection
  //     LIMIT @page_size OFFSET @offset;
  //     ''';

  //     params['page_size'] = pageSize;
  //     params['offset'] = offset;

  //     print('final query: $finalQuery');
  //     print('params: $params');

  //     final results = await _conn.execute(
  //       Sql.named(finalQuery),
  //       parameters: params,
  //     );

  //     print('raw res: $results');

  //     for (final row in results) {
  //       final itemWithStockMap = {
  //         'item_id': row[0],
  //         'product_name_id': row[1],
  //         'product_description_id': row[2],
  //         'manufacturer_id': row[3],
  //         'brand_id': row[4],
  //         'model_id': row[5],
  //         'serial_no': row[6],
  //         'specification': row[7],
  //         'asset_classification': row[8],
  //         'asset_sub_class': row[9],
  //         'unit': row[10],
  //         'quantity': row[11],
  //         'unit_cost': row[12],
  //         'estimated_useful_life': row[13],
  //         'acquired_date': row[14],
  //         'encrypted_id': row[15],
  //         'qr_code_image_data': row[16],
  //         'product_name': row[17],
  //         'product_description': row[18],
  //         'manufacturer_name': row[19],
  //         'brand_name': row[20],
  //         'model_name': row[21],
  //       };
  //       itemList.add(ItemWithStock.fromJson(itemWithStockMap));
  //     }
  //     print('Fetched items for page $page: ${itemList.length}');
  //     return itemList;
  //   } catch (e) {
  //     print('Error fetching items: $e');
  //     throw Exception('Failed to fetch users.');
  //   }
  // }

  Future<BaseItemModel?> getItemById({
    required String id,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT
            i.*,
            pn.name as product_name,
            pd.description as product_description,
            s.id as supply_id,
            e.id as equipment_id,
            e.manufacturer_id,
            e.brand_id,
            e.model_id,
            e.serial_no,
            e.asset_classification,
            e.asset_sub_class,
            e.estimated_useful_life,
            mnf.name as manufacturer_name,
            brnd.name as brand_name,
            md.model_name
          FROM
            Items i
          LEFT JOIN
            ProductNames pn ON i.product_name_id = pn.id
          LEFT JOIN
            ProductDescriptions pd ON i.product_description_id = pd.id
          LEFT JOIN
            Supplies s ON i.id = s.base_item_id
          LEFT JOIN
            Equipment e ON i.id = e.base_item_id
          LEFT JOIN
            Manufacturers mnf ON e.manufacturer_id =  mnf.id
          LEFT JOIN
            Brands brnd ON e.brand_id = brnd.id
          LEFT JOIN
            Models md ON e.model_id = md.id
          WHERE
            i.id = @id;
          ''',
        ),
        parameters: {
          'id': id,
        },
      );

      final row = result.first;

      if (row[12] != null) {
        final supplyMap = {
          'supply_id': row[12],
          'base_item_id': row[0],
          'product_name_id': row[1],
          'product_description_id': row[2],
          'specification': row[3],
          'unit': row[4],
          'quantity': row[5],
          'encrypted_id': row[6],
          'qr_code_image_data': row[7],
          'unit_cost': row[8],
          'acquired_date': row[9],
          'product_name': row[10],
          'product_description': row[11],
        };
        return Supply.fromJson(supplyMap);
      } else if (row[13] != null) {
        final equipmentMap = {
          'equipment_id': row[13],
          'base_item_id': row[0],
          'product_name_id': row[1],
          'product_description_id': row[2],
          'specification': row[3],
          'unit': row[4],
          'quantity': row[5],
          'encrypted_id': row[6],
          'qr_code_image_data': row[7],
          'unit_cost': row[8],
          'acquired_date': row[9],
          'product_name': row[10],
          'product_description': row[11],
          'manufacturer_id': row[14],
          'brand_id': row[15],
          'model_id': row[16],
          'serial_no': row[17],
          'asset_classification': row[18],
          'asset_sub_class': row[19],
          'estimated_useful_life': row[20],
          'manufacturer_name': row[21],
          'brand_name': row[22],
          'model_name': row[23],
        };
        return Equipment.fromJson(equipmentMap);
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool?> updateItemInformation({
    required String id,
    String? productName,
    String? description,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
    String? specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    Unit? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      final List<String> baseItemSetClauses = [];
      final List<String> equipmentSetClauses = [];

      final Map<String, dynamic> baseItemParams = {
        'id': id,
      };
      final Map<String, dynamic> equipmentParams = {
        'id': id,
      };

      int? productNameId;
      int? productDescriptionId;
      String? manufacturerId;
      String? brandId;
      String? modelId;

      if (productName != null && productName.isNotEmpty) {
        final productNameResult = await checkProductNameIfExist(
          productName: productName,
        );

        if (productNameResult != null) {
          productNameId = productNameResult;
        } else {
          productNameId = await registerProductName(
            productName: productName,
          );
          print('product name does not exist; created id: $productNameId');
        }

        baseItemSetClauses.add('product_name_id = @product_name_id');
        baseItemParams['product_name_id'] = productNameId;
      }

      if ((productNameId != null) &&
          (description != null && description.isNotEmpty)) {
        final productDescriptionResult = await checkProductDescriptionIfExist(
          productDescription: description,
        );

        if (productDescriptionResult != null) {
          productDescriptionId = productDescriptionResult;
        } else {
          productDescriptionId = await registerProductDescription(
            productDescription: description,
          );
          print(
              'product desc does not exist; created id: $productDescriptionId');
        }

        final productStockResult = await checkProductStockIfExist(
          productNameId: productNameId,
          productDescriptionId: productDescriptionId,
        );

        if (productStockResult == 0) {
          await registerProductStock(
            productNameId: productNameId,
            productDescriptionId: productDescriptionId,
          );
          print('product stock does not exist; created one.');
        }

        baseItemSetClauses
            .add('product_description_id = @product_description_id');
        baseItemParams['product_description_id'] = productDescriptionId;
      }

      if (specification != null) {
        baseItemSetClauses.add('specification = @specification');
        baseItemParams['specification'] = specification;
      }

      if (unit != null) {
        baseItemSetClauses.add('unit = @unit');
        baseItemParams['unit'] = unit.toString().split('.').last;
      }

      if (quantity != null) {
        baseItemSetClauses.add('quantity = @quantity');
        baseItemParams['quantity'] = quantity;

        /// log update to inventory activity
        await updateInventoryQuantity(
          baseItemId: id,
          newQuantity: quantity,
        );
      }

      if (unitCost != null) {
        baseItemSetClauses.add('unit_cost = @unit_cost');
        baseItemParams['unit_cost'] = unitCost;
      }

      if (acquiredDate != null) {
        baseItemSetClauses.add('acquired_date = @acquired_date');
        baseItemParams['acquired_date'] = acquiredDate;
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        final manufacturerResult = await checkManufacturerIfExist(
          manufacturerName: manufacturerName,
        );

        if (manufacturerResult != null) {
          manufacturerId = manufacturerResult;
        } else {
          manufacturerId = await registerManufacturer(
            manufacturerName: manufacturerName,
          );
          print('manufacturer does not exist; created id: $manufacturerId');
        }

        equipmentSetClauses.add('manufacturer_id = @manufacturer_id');
        equipmentParams['manufacturer_id'] = manufacturerId;
      }

      if ((manufacturerId != null && manufacturerId.isNotEmpty) &&
          (brandName != null && brandName.isNotEmpty)) {
        final brandResult = await checkBrandIfExist(
          brandName: brandName,
        );

        if (brandResult != null) {
          brandId = brandResult;
        } else {
          brandId = await registerBrand(
            brandName: brandName,
          );
          print('brand does not exist; created id: $brandId');
        }

        final manufacturerBrandResult = await checkManufacturerBrandIfExist(
          manufacturerId: manufacturerId,
          brandId: brandId,
        );

        if (manufacturerBrandResult == 0) {
          await registerManufacturerBrand(
            manufacturerId: manufacturerId,
            brandId: brandId,
          );
          print('manufacturer brand does not exist; created one.');
        }

        equipmentSetClauses.add('brand_id = @brand_id');
        equipmentParams['brand_id'] = brandId;
      }

      if ((productNameId != null) &&
          (brandId != null && brandId.isNotEmpty) &&
          (modelName != null && modelName.isNotEmpty)) {
        final modelResult = await checkModelIfExist(
          productNameId: productNameId,
          brandId: brandId,
          modelName: modelName,
        );

        if (modelResult != null) {
          modelId = modelResult;
        } else {
          modelId = await registerModel(
            productNameId: productNameId,
            brandId: brandId,
            modelName: modelName,
          );
          print('model does not exist; created id: $modelId');
        }
        print('model id: $modelId');

        equipmentSetClauses.add('model_id = @model_id');
        equipmentParams['model_id'] = modelId;
      }

      if (serialNo != null) {
        equipmentSetClauses.add('serial_no = @serial_no');
        equipmentParams['serial_no'] = serialNo;
      }

      if (assetClassification != null) {
        equipmentSetClauses.add('asset_classification = @asset_classification');
        equipmentParams['asset_classification'] =
            assetClassification.toString().split('.').last;
      }

      if (assetSubClass != null) {
        equipmentSetClauses.add('asset_sub_class = @asset_sub_class');
        equipmentParams['asset_sub_class'] =
            assetSubClass.toString().split('.').last;
      }

      if (estimatedUsefulLife != null) {
        equipmentSetClauses
            .add('estimated_useful_life = @estimated_useful_life');
        equipmentParams['estimated_useful_life'] = estimatedUsefulLife;
      }

      await _conn.execute(
        Sql.named(
          '''
          UPDATE Items
          SET ${baseItemSetClauses.join(', ')}
          WHERE id = @id;
          ''',
        ),
        parameters: baseItemParams,
      );

      if (equipmentSetClauses.isNotEmpty) {
        await _conn.execute(
          Sql.named(
            '''
          UPDATE Equipment
          SET ${equipmentSetClauses.join(', ')}
          WHERE base_item_id = @id;
          ''',
          ),
          parameters: equipmentParams,
        );
      }

      return true;
    } catch (e) {
      if (e.toString().contains(
          'duplicate key value violates unique constraints "items_serial_no_key"')) {
        throw Exception('Serial no. already exists.');
      }
      throw Exception('Error updating item: $e');
    }
  }

  Future<int> getStocksProductNameFilteredCount({
    String? productName,
  }) async {
    Map<String, dynamic> param = {};
    String baseQuery = '''
    SELECT COUNT(name) FROM ProductNames
    ''';

    if (productName != null && productName.isNotEmpty) {
      baseQuery += 'WHERE name ILIKE @name';
      param['name'] = '%$productName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: param,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getStocksProductName({
    required int page,
    required int pageSize,
    String? productName,
  }) async {
    final offset = (page - 1) * pageSize;
    final productNames = <String>[];
    final Map<String, dynamic> params = {};

    String baseQuery = '''
      SELECT name FROM ProductNames
      ''';

    if (productName != null && productName.isNotEmpty) {
      baseQuery += ' WHERE name ILIKE @name';
      params['name'] = '%$productName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        productNames.add(row[0] as String);
      }
      return productNames;
    }
    return null;
  }

  Future<int> getStocksDescriptionFilteredCount({
    required int productNameId,
    String? productDescription,
  }) async {
    Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT COUNT(pd.description)
    FROM ProductDescriptions pd
    JOIN ProductStocks ps ON pd.id = ps.product_description_id
    JOIN ProductNames pn ON pn.id = ps.product_name_id
    ''';

    baseQuery += ' WHERE pn.id = @id';
    params['id'] = productNameId;

    if (productDescription != null && productDescription.isNotEmpty) {
      baseQuery += ' AND pd.description ILIKE @description';
      params['description'] = '%$productDescription%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: params,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getStocksDescription({
    required int page,
    required int pageSize,
    required int productNameId,
    String? productDescription,
  }) async {
    print(productNameId);
    final offset = (page - 1) * pageSize;
    final descriptions = <String>[];
    Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT pd.description
    FROM ProductDescriptions pd
    JOIN ProductStocks ps ON pd.id = ps.product_description_id
    JOIN ProductNames pn ON pn.id = ps.product_name_id
    ''';

    baseQuery += 'WHERE pn.id = @id';
    params['id'] = productNameId;

    if (productDescription != null && productDescription.isNotEmpty) {
      baseQuery += ' AND pd.description ILIKE @description';
      params['description'] = '%$productDescription%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY pd.description ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        final description = row[0] as String? ?? '';
        descriptions.add(description);
      }
      return descriptions;
    }
    return null;
  }

  Future<int> getManufacturerNamesFilteredCount({
    String? manufacturerName,
  }) async {
    Map<String, dynamic> param = {};
    String baseQuery = '''
    SELECT COUNT(*) FROM Manufacturers
    ''';

    if (manufacturerName != null && manufacturerName.isNotEmpty) {
      baseQuery += 'WHERE name ILIKE @name';
      param['name'] = '%$manufacturerName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: param,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getManufacturerNames({
    required int page,
    required int pageSize,
    String? manufacturerName,
  }) async {
    final offset = (page - 1) * pageSize;
    final manufacturerNames = <String>[];
    final Map<String, dynamic> params = {};

    String baseQuery = '''
      SELECT name FROM Manufacturers
      ''';

    if (manufacturerName != null && manufacturerName.isNotEmpty) {
      baseQuery += ' WHERE name ILIKE @name';
      params['name'] = '%$manufacturerName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        manufacturerNames.add(row[0] as String);
      }
      return manufacturerNames;
    }
    return null;
  }

  Future<int> getManufacturerBrandNamesFilteredCount({
    required String manufacturerId,
    String? brandName,
  }) async {
    Map<String, dynamic> params = {};
    String baseQuery = '''
    SELECT COUNT(b.name)
    FROM Brands b
    JOIN ManufacturerBrands mb ON b.id = mb.brand_id
    JOIN Manufacturers m ON m.id = mb.manufacturer_id 
      ''';

    if (manufacturerId.isNotEmpty) {
      baseQuery += 'WHERE m.id = @manufacturer_id';
      params['manufacturer_id'] = manufacturerId;
    }

    if (brandName != null && brandName.isNotEmpty) {
      baseQuery += ' AND b.name ILIKE @brand_name';
      params['brand_name'] = '%$brandName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: params,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getManufacturerBrandNames({
    required int page,
    required int pageSize,
    required String manufacturerId,
    String? brandName,
  }) async {
    final offset = (page - 1) * pageSize;
    final brandNames = <String>[];
    Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT b.name
    FROM Brands b
    JOIN ManufacturerBrands mb ON b.id = mb.brand_id
    JOIN Manufacturers m ON m.id = mb.manufacturer_id 
      ''';

    if (manufacturerId.isNotEmpty) {
      baseQuery += 'WHERE m.id = @manufacturer_id';
      params['manufacturer_id'] = manufacturerId;
    }

    if (brandName != null && brandName.isNotEmpty) {
      baseQuery += ' AND b.name ILIKE @brand_name';
      params['brand_name'] = '%$brandName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY b.name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        brandNames.add(row[0] as String);
      }
      return brandNames;
    }
    return null;
  }

  Future<int> getBrandModelsFilteredCount({
    required int productNameId,
    required String brandId,
    String? modelName,
  }) async {
    Map<String, dynamic> params = {};
    String baseQuery = '''
    SELECT COUNT(model_name) FROM Models
      ''';

    if (brandId.isNotEmpty) {
      baseQuery += ' WHERE product_name_id = @product_name_id';
      baseQuery += ' AND brand_id = @brand_id';

      params['product_name_id'] = productNameId;
      params['brand_id'] = brandId;
    }

    if (modelName != null && modelName.isNotEmpty) {
      baseQuery += ' AND model_name ILIKE @model_name';

      params['model_name'] = '%$modelName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: params,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getBrandModelNames({
    required int page,
    required int pageSize,
    required int productNameId,
    required String brandId,
    String? modelName,
  }) async {
    final offset = (page - 1) * pageSize;
    final productNames = <String>[];
    final Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT model_name FROM Models
      ''';

    if (brandId.isNotEmpty) {
      baseQuery += ' WHERE product_name_id = @product_name_id';
      baseQuery += ' AND brand_id = @brand_id';

      params['product_name_id'] = productNameId;
      params['brand_id'] = brandId;
    }

    if (modelName != null && modelName.isNotEmpty) {
      baseQuery += ' AND model_name ILIKE @model_name';

      params['model_name'] = '%$modelName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY model_name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        productNames.add(row[0] as String);
      }
      print(productNames);
      return productNames;
    }
    return null;
  }

  Future<int> getSuppliesCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT COUNT (*) AS supplies_count FROM Supplies;
        ''',
      ),
    );

    return result.first[0] as int;
  }

  Future<int> getEquipmentCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT COUNT(*) AS equipment_count FROM Equipment;
        ''',
      ),
    );

    return result.first[0] as int;
  }

  Future<int> getOutOfStocksCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT 
          COUNT(*) AS out_of_stock_count
        FROM (
          SELECT 
            pn.name AS product_name,
            SUM(i.quantity) AS total_quantity
          FROM 
            Items i
          JOIN 
            ProductNames pn ON i.product_name_id = pn.id
          GROUP BY 
            pn.name
          HAVING 
            SUM(i.quantity) = 0
        ) AS out_of_stock_count;
        ''',
      ),
    );

    return result.first[0] as int;
  }

  Future<List<Map<String, dynamic>>> getCategoricalInventory() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT
          i.asset_classification AS category_name,
          SUM(i.quantity) AS total_stock
        FROM 
          Items i
        GROUP BY 
          i.asset_classification
        ORDER BY 
          total_stock DESC;
        ''',
      ),
    );

    return result
        .map((row) => {
              'category_name': row[0],
              'total_stock': row[1],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getLowStockItems({
    required int page,
    required int pageSize,
  }) async {
    final offset = (page - 1) * pageSize;
    final lowStockItems = <Map<String, dynamic>>[];

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT 
          pn.name AS product_name,
          pd.description AS product_description,
          i.specification,
          i.quantity
        FROM 
          Items i
        JOIN 
          Supplies s ON i.id = s.base_item_id
        JOIN 
          ProductNames pn ON i.product_name_id = pn.id
        JOIN 
          ProductDescriptions pd ON i.product_description_id = pd.id
        WHERE 
          i.quantity > 0 AND i.quantity < 10
        ORDER BY
          product_name ASC 
        LIMIT 
          @page_size OFFSET @offset;
        ''',
      ),
      parameters: {
        'page_size': pageSize,
        'offset': offset,
      },
    );

    for (var row in result) {
      lowStockItems.add({
        'product_name': row[0],
        'product_description': row[1],
        'specification': row[2],
        'quantity': row[3],
      });
    }

    return lowStockItems;
  }

  Future<int> getLowStockItemsFilteredCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT
          COUNT(*)
        FROM
          Items i
        JOIN
          Supplies s ON i.id = s.base_item_id
        WHERE 
          i.quantity > 0 AND i.quantity < 10
        ''',
      ),
    );

    return result.first[0] as int;
  }

  Future<List<Map<String, dynamic>>> getOutOfStockItems({
    required int page,
    required int pageSize,
  }) async {
    final offset = (page - 1) * pageSize;
    final outOfStockItems = <Map<String, dynamic>>[];

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT 
          pn.name AS product_name,
          pd.description AS product_description,
          i.specification
        FROM 
          Items i
        JOIN 
          Supplies s ON i.id = s.base_item_id
        JOIN 
          ProductNames pn ON i.product_name_id = pn.id
        JOIN 
          ProductDescriptions pd ON i.product_description_id = pd.id
        WHERE 
          i.quantity = 0
        ORDER BY
          product_name ASC 
        LIMIT @page_size OFFSET @offset;
        ''',
      ),
      parameters: {
        'page_size': pageSize,
        'offset': offset,
      },
    );

    for (var row in result) {
      outOfStockItems.add({
        'product_name': row[0],
        'product_description': row[1],
        'specification': row[2],
      });
    }

    return outOfStockItems;
  }

  Future<int> getOutOfStockItemsFilteredCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT
          COUNT(*)
        FROM
          Items i
        JOIN
          Supplies s ON i.id = s.base_item_id
        WHERE 
          i.quantity = 0
        ''',
      ),
    );

    return result.first[0] as int;
  }

  Future<Map<String, dynamic>> getWeeklyTrendsWithPercentage() async {
    // final result = await _conn.execute(
    //   Sql.named(
    //     '''
    //   WITH weekly_totals AS (
    //       SELECT
    //           DATE_TRUNC('week', ia.timestamp) AS week_start,
    //           CASE
    //               WHEN s.id IS NOT NULL THEN 'Supply'
    //               WHEN e.id IS NOT NULL THEN 'Equipment'
    //               ELSE 'Unknown'
    //           END AS item_type,
    //           SUM(ia.quantity) AS total_quantity
    //       FROM
    //           inventoryactivities ia
    //       JOIN
    //           items i ON ia.base_item_id = i.id
    //       LEFT JOIN
    //           supplies s ON i.id = s.base_item_id
    //       LEFT JOIN
    //           equipment e ON i.id = e.base_item_id
    //       GROUP BY
    //           week_start, item_type
    //       ORDER BY
    //           week_start DESC
    //       LIMIT 6 -- Fetch data for the last 6 weeks
    //   )
    //   SELECT
    //       week_start,
    //       item_type,
    //       total_quantity
    //   FROM
    //       weekly_totals;
    // ''',
    //   ),
    // );

    final result = await _conn.execute(
      Sql.named(
        '''
      WITH weekly_totals AS (
          SELECT
              DATE_TRUNC('week', ia.timestamp) AS week_start,
              CASE 
                  WHEN s.id IS NOT NULL THEN 'Supply'
                  WHEN e.id IS NOT NULL THEN 'Equipment'
                  ELSE 'Unknown'
              END AS item_type,
              SUM(ia.quantity) AS total_quantity
          FROM
              inventoryactivities ia
          JOIN
              items i ON ia.base_item_id = i.id
          LEFT JOIN 
              supplies s ON i.id = s.base_item_id
          LEFT JOIN 
              equipment e ON i.id = e.base_item_id
          WHERE ia.timestamp >= NOW() - INTERVAL '6 weeks'
          GROUP BY
              week_start, item_type
      )
      SELECT
          week_start,
          item_type,
          total_quantity
      FROM
          weekly_totals
      ORDER BY
          week_start ASC;
    ''',
      ),
    );

    if (result.isEmpty || result.length < 2) {
      return {
        'trends': [],
        'percentage_change': null,
      };
    }

    // Extract trends for Supply and Equipment
    var supplyTrends = <Map<String, dynamic>>[];
    var equipmentTrends = <Map<String, dynamic>>[];

    for (var row in result) {
      final trend = {
        'week_start': (row[0] as DateTime).toIso8601String(),
        'item_type': row[1],
        'total_quantity': row[2],
      };
      if (row[1] == 'Supply') {
        supplyTrends.add(trend);
      } else if (row[1] == 'Equipment') {
        equipmentTrends.add(trend);
      }
    }

    // Calculate percentage change for Supply and Equipment separately
    double supplyPercentageChange = 0;
    double equipmentPercentageChange = 0;

    if (supplyTrends.length > 1) {
      final currentWeekSupply =
          (supplyTrends[0]['total_quantity'] as int?) ?? 0;
      final previousWeekSupply =
          (supplyTrends[1]['total_quantity'] as int?) ?? 0;
      supplyPercentageChange = previousWeekSupply == 0
          ? 0
          : ((currentWeekSupply - previousWeekSupply) / previousWeekSupply) *
              100;
      supplyPercentageChange =
          double.parse(supplyPercentageChange.toStringAsFixed(2));
    }

    if (equipmentTrends.length > 1) {
      final currentWeekEquipment =
          (equipmentTrends[0]['total_quantity'] as int?) ?? 0;
      final previousWeekEquipment =
          (equipmentTrends[1]['total_quantity'] as int?) ?? 0;
      equipmentPercentageChange = previousWeekEquipment == 0
          ? 0
          : ((currentWeekEquipment - previousWeekEquipment) /
                  previousWeekEquipment) *
              100;
      equipmentPercentageChange =
          double.parse(equipmentPercentageChange.toStringAsFixed(2));
    }

    return {
      'supply_trends': supplyTrends,
      'equipment_trends': equipmentTrends,
      'supply_percentage_change': supplyPercentageChange,
      'equipment_percentage_change': equipmentPercentageChange,
    };
  }

  Future<List<Map<String, dynamic>>> getInventoryStockLevels() async {
    final result = await _conn.execute(
      Sql.named(
        '''
      SELECT
          CASE
              WHEN s.id IS NOT NULL THEN 'Supply'
              WHEN e.id IS NOT NULL THEN 'Equipment'
              ELSE 'Unknown'
          END AS item_type,
          SUM(i.quantity) AS total_stock
      FROM
          items i
      LEFT JOIN
          supplies s ON i.id = s.base_item_id
      LEFT JOIN
          equipment e ON i.id = e.base_item_id
      GROUP BY
          item_type;
      ''',
      ),
    );

    final List<Map<String, dynamic>> stockLevels = [];
    for (var row in result) {
      stockLevels.add(
        {
          'item_type': row[0] as String,
          'total_stock': row[1] as int,
        },
      );
    }

    return stockLevels;
  }

  Future<bool> registerInventoryActivity({
    required String baseItemId,
    required InventoryActivity action,
    required int quantity,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''
          INSERT INTO InventoryActivities (
            base_item_id, action, quantity, timestamp
          ) VALUES (
            @base_item_id, @action, @quantity, @timestamp
          );
          ''',
        ),
        parameters: {
          'base_item_id': baseItemId,
          'action': action.toString().split('.').last,
          'quantity': quantity,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return result.affectedRows == 1;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> updateInventoryQuantity({
    required String baseItemId,
    required int newQuantity,
  }) async {
    try {
      final currentQuantityResult = await _conn.execute(
        Sql.named(
          '''
        SELECT SUM(quantity) AS current_quantity
        FROM InventoryActivities
        WHERE base_item_id = @base_item_id;
        ''',
        ),
        parameters: {
          'base_item_id': baseItemId,
        },
      );

      final currentQuantity =
          currentQuantityResult.firstOrNull?[0] as int? ?? 0;

      print('curr qty: $currentQuantity');

      final quantityDifference = newQuantity - currentQuantity;

      print('qty diff: $quantityDifference');

      final result = await registerInventoryActivity(
        baseItemId: baseItemId,
        action: InventoryActivity.updated,
        quantity: quantityDifference,
      );

      return result;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
