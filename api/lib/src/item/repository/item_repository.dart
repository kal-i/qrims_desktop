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

  // Future<String> _generateUniqueItemId(
  //   TxSession? ctx,
  //   String itemName,
  //   FundCluster? fundCluster,
  //   DateTime? acquiredDate,
  // ) async {
  //   final conn = ctx ?? _conn;
  //   final now = DateTime.now();
  //   final dateToUse = acquiredDate ?? now;
  //   final year = dateToUse.year;
  //   final month = dateToUse.month.toString().padLeft(2, '0');

  //   // Format item name (e.g., "Office Chair" → "OfficeChair")
  //   final formattedItemName = itemName
  //       .split(' ')
  //       .map((word) => word[0].toUpperCase() + word.substring(1))
  //       .join('');

  //   // NNN: Count items for the same year
  //   final latestYearlyResult = await conn.execute(
  //     Sql.named('''
  //     SELECT id FROM Items
  //     WHERE id ILIKE @item_name || '-' || @year || '%'
  //     ORDER BY id DESC
  //     LIMIT 1;
  //     '''),
  //     parameters: {
  //       'item_name': formattedItemName,
  //       'year': year.toString(),
  //     },
  //   );

  //   int cumulativeCount;
  //   if (latestYearlyResult.isNotEmpty && latestYearlyResult.first[0] != null) {
  //     final latestId = latestYearlyResult.first[0].toString();
  //     final countMatch = RegExp(r'-(\d{3})\(').firstMatch(latestId);
  //     cumulativeCount =
  //         countMatch != null ? int.parse(countMatch.group(1)!) + 1 : 1;
  //   } else {
  //     cumulativeCount = 1;
  //   }

  //   // (N): Count items for the same date
  //   final dailyDate = dateToUse.toIso8601String().split('T').first;

  //   final latestDailyResult = await conn.execute(
  //     Sql.named('''
  //     SELECT id FROM Items
  //     WHERE id ILIKE @item_name || '-%' AND DATE(acquired_date) = @daily_date
  //     ORDER BY id DESC
  //     LIMIT 1;
  //     '''),
  //     parameters: {
  //       'item_name': formattedItemName,
  //       'daily_date': dailyDate,
  //     },
  //   );

  //   int itemSpecificCount;
  //   if (latestDailyResult.isNotEmpty && latestDailyResult.first[0] != null) {
  //     final latestId = latestDailyResult.first[0].toString();
  //     final countMatch = RegExp(r'\((\d+)\)$').firstMatch(latestId);
  //     itemSpecificCount =
  //         countMatch != null ? int.parse(countMatch.group(1)!) + 1 : 1;
  //   } else {
  //     itemSpecificCount = 1;
  //   }

  //   // Construct the unique item ID
  //   final uniqueId = fundCluster != null
  //       ? '$formattedItemName-$year(${fundCluster.value})-$month-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)'
  //       : '$formattedItemName-$year-$month-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)';

  //   return uniqueId;
  // }

  Future<String> _generateUniqueItemId(
    TxSession? ctx,
    String itemName,
    int productDescriptionId,
    FundCluster? fundCluster,
    DateTime? acquiredDate,
  ) async {
    final conn = ctx ?? _conn;
    final now = DateTime.now();
    final dateToUse = acquiredDate ?? now;
    final year = dateToUse.year;
    final month = dateToUse.month.toString().padLeft(2, '0');
    final dailyDate = dateToUse.toIso8601String().split('T').first;

    // Format item name
    final formattedItemName = itemName
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');

    Future<int> getYearlyCount() async {
      // First lock existing rows
      await conn.execute(
        Sql.named('''
        SELECT id FROM Items
        WHERE id LIKE @item_name || '-' || @year || '%'
        FOR UPDATE;
        '''),
        parameters: {
          'item_name': formattedItemName,
          'year': year.toString(),
        },
      );

      // Then get count
      final result = await conn.execute(
        Sql.named('''
        SELECT COUNT(*) FROM Items
        WHERE id LIKE @item_name || '-' || @year || '%';
        '''),
        parameters: {
          'item_name': formattedItemName,
          'year': year.toString(),
        },
      );
      return result.first[0] as int;
    }

    Future<int> getDailyCount() async {
      // First lock existing rows
      await conn.execute(
        Sql.named('''
        SELECT id FROM Items
        WHERE id LIKE @item_name || '-%' 
          AND DATE(acquired_date) = @daily_date
          AND product_description_id = @product_description_id
        FOR UPDATE;
        '''),
        parameters: {
          'item_name': formattedItemName,
          'daily_date': dailyDate,
          'product_description_id': productDescriptionId,
        },
      );

      // Then get count
      final result = await conn.execute(
        Sql.named('''
        SELECT COUNT(*) FROM Items
        WHERE id LIKE @item_name || '-%' 
          AND DATE(acquired_date) = @daily_date
          AND product_description_id = @product_description_id;
        '''),
        parameters: {
          'item_name': formattedItemName,
          'daily_date': dailyDate,
          'product_description_id': productDescriptionId,
        },
      );
      return result.first[0] as int;
    }

    // If we're already in a transaction (ctx provided)
    if (ctx != null) {
      final yearlyCount = await getYearlyCount();
      final dailyCount = await getDailyCount();

      return fundCluster != null
          ? '$formattedItemName-$year(${fundCluster.value})-$month-${(yearlyCount + 1).toString().padLeft(3, '0')}(${dailyCount + 1})'
          : '$formattedItemName-$year-$month-${(yearlyCount + 1).toString().padLeft(3, '0')}(${dailyCount + 1})';
    }
    // If we need to create a new transaction
    else {
      return await (conn as Connection).runTx((tx) async {
        final yearlyCount = await getYearlyCount();
        final dailyCount = await getDailyCount();

        return fundCluster != null
            ? '$formattedItemName-$year(${fundCluster.value})-$month-${(yearlyCount + 1).toString().padLeft(3, '0')}(${dailyCount + 1})'
            : '$formattedItemName-$year-$month-${(yearlyCount + 1).toString().padLeft(3, '0')}(${dailyCount + 1})';
      });
    }
  }

  // Future<String> _generateUniqueItemId(
  //   TxSession? ctx,
  //   String itemName,
  //   FundCluster? fundCluster,
  //   DateTime? acquiredDate,
  // ) async {
  //   final conn = ctx ?? _conn;
  //   final now = DateTime.now();
  //   final dateToUse = acquiredDate ?? now;
  //   final year = dateToUse.year;
  //   final month = dateToUse.month.toString().padLeft(2, '0');

  //   // Format item name (e.g., "Office Chair" → "OfficeChair")
  //   final formattedItemName = itemName
  //       .split(' ')
  //       .map((word) => word[0].toUpperCase() + word.substring(1))
  //       .join('');

  //   // Check for existing entries for this item + year + month + FC
  //   final latestEntryResult = await conn.execute(
  //     Sql.named(
  //       '''
  //     SELECT id FROM Items
  //     WHERE id ILIKE @item_name || '-' || @year ||
  //           CASE WHEN @fundCluster != '' THEN '(' || @fundCluster || ')' ELSE '' END ||
  //           '-' || @month || '-%'
  //     ORDER BY id DESC
  //     LIMIT 1;
  //     ''',
  //     ),
  //     parameters: {
  //       'item_name': formattedItemName,
  //       'year': year.toString(),
  //       'month': month,
  //       'fundCluster': fundCluster?.value ?? '',
  //     },
  //   );

  //   int cumulativeCount;
  //   if (latestEntryResult.isNotEmpty && latestEntryResult.first[0] != null) {
  //     // Extract NNN from the latest ID (e.g., "002" from "Printer-2024(GAA)-05-002(2)")
  //     final latestId = latestEntryResult.first[0].toString();
  //     final countMatch = RegExp(r'-(\d{3})\(').firstMatch(latestId);
  //     cumulativeCount =
  //         countMatch != null ? int.parse(countMatch.group(1)!) + 1 : 1;
  //   } else {
  //     // Reset to 001 if new month/year/FC
  //     cumulativeCount = 1;
  //   }

  //   // Item-specific count (for the trailing (N))
  //   int itemSpecificCount;
  //   if (latestEntryResult.isNotEmpty && latestEntryResult.first[0] != null) {
  //     final latestId = latestEntryResult.first[0].toString();
  //     final countMatch = RegExp(r'\((\d+)\)$').firstMatch(latestId);
  //     itemSpecificCount =
  //         countMatch != null ? int.parse(countMatch.group(1)!) + 1 : 1;
  //   } else {
  //     itemSpecificCount = 1;
  //   }

  //   // Construct the ID (NNN resets on new month/year/FC)
  //   final uniqueId = fundCluster != null
  //       ? '$formattedItemName-$year(${fundCluster.value})-$month-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)'
  //       : '$formattedItemName-$year-$month-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)';

  //   return uniqueId;
  // }

  Future<String> _generateUniqueManufacturerId(
    TxSession? ctx,
  ) async {
    final conn = ctx ?? _conn;
    while (true) {
      final manufacturerId = generatedId('MNFCTR');

      final result = await conn.execute(
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

  Future<String> _generateUniqueBrandId(TxSession? ctx) async {
    final conn = ctx ?? _conn;
    while (true) {
      final brandId = generatedId('BRND');

      final result = await conn.execute(
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

  Future<String> _generateUniqueModelId(TxSession? ctx) async {
    final conn = ctx ?? _conn;
    while (true) {
      final modelId = generatedId('MDL');

      final result = await conn.execute(
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
    int? stockNo,
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
        null,
        productName,
        0,
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
          stockNo: stockNo,
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
    TxSession? ctx,
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
      final conn = ctx ?? _conn;

      /// generate an item id
      final itemId = await _generateUniqueItemId(
        ctx,
        productName,
        productDescriptionId ?? 0,
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

      await conn.execute(
        Sql.named(
          '''
        INSERT INTO Items (
          id, product_name_id, product_description_id, specification, unit, 
          quantity, unit_cost, encrypted_id, qr_code_image_data, acquired_date,
          fund_cluster
        ) VALUES (
          @id, @product_name_id, @product_description_id, @specification, @unit,
          @quantity, @unit_cost, @encrypted_id, @qr_code_image_data, 
          @acquired_date, @fund_cluster
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
          'fund_cluster': fundCluster.toString().split('.').last,
        },
      );

      print('insertion successful');

      return itemId;
    } catch (e) {
      throw Exception('Error registering base item entity: $e');
    }
  }

  Future<String?> checkSupplyIfExist({
    TxSession? ctx,
    required int productNameId,
    required int productDescriptionId,
    String? specification,
    required Unit unit,
    required double unitCost,
    DateTime? acquiredDate,
    FundCluster? fundCluster,
  }) async {
    final conn = ctx ?? _conn;
    final baseItemResult = await conn.execute(
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
          (acquired_date IS NULL OR acquired_date::DATE = @acquired_date::DATE)
        AND 
          fund_cluster = @fund_cluster
        ''',
      ),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
        'specification': specification,
        'unit': unit.toString().split('.').last,
        'unit_cost': unitCost,
        'acquired_date': acquiredDate,
        'fund_cluster': fundCluster.toString().split('.').last,
      },
    );

    if (baseItemResult.isNotEmpty) {
      String baseItemId = baseItemResult.first[0] as String;

      final supplyItemResult = await conn.execute(
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
    TxSession? ctx,
    required String baseItemId,
    required int quantity,
  }) async {
    final conn = ctx ?? _conn;
    final result = await conn.execute(
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
    TxSession? ctx,
    required String baseItemModelId,
  }) async {
    try {
      final conn = ctx ?? _conn;
      await conn.execute(
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

  Future<String> registerInventoryItem({
    TxSession? ctx,
    required String baseItemModelId,
    required int productNameId,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    int? estimatedUsefulLife,
  }) async {
    try {
      final conn = ctx ?? _conn;

      String? manufacturerId;
      String? brandId;
      String? modelId;

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        /// check if manufacturer exists
        final manufacturerResult = await checkManufacturerIfExist(
          ctx: ctx,
          manufacturerName: manufacturerName,
        );

        manufacturerId = manufacturerResult ??
            await registerManufacturer(
              ctx: ctx,
              manufacturerName: manufacturerName,
            );

        print('manufacturer id: $manufacturerId');
      }

      if (brandName != null && brandName.isNotEmpty) {
        /// check if brand exists
        final brandResult = await checkBrandIfExist(
          ctx: ctx,
          brandName: brandName,
        );

        brandId = brandResult ??
            await registerBrand(
              ctx: ctx,
              brandName: brandName,
            );

        print('brand id: $brandId');
      }

      if ((manufacturerId != null && manufacturerId.isNotEmpty) &&
          (brandId != null && brandId.isNotEmpty)) {
        final manufacturerBrandResult = await checkManufacturerBrandIfExist(
          ctx: ctx,
          manufacturerId: manufacturerId,
          brandId: brandId,
        );

        if (manufacturerBrandResult == 0) {
          await registerManufacturerBrand(
            ctx: ctx,
            manufacturerId: manufacturerId,
            brandId: brandId,
          );
        }
      }

      if ((brandId != null && brandId.isNotEmpty) &&
          (modelName != null && modelName.isNotEmpty)) {
        /// check if model exists
        final modelResult = await checkModelIfExist(
          ctx: ctx,
          productNameId: productNameId,
          brandId: brandId,
          modelName: modelName,
        );

        modelId = modelResult ??
            await registerModel(
              ctx: ctx,
              productNameId: productNameId,
              brandId: brandId,
              modelName: modelName,
            );

        print('model id: $modelId');
      }

      await conn.execute(
        Sql.named(
          '''
        INSERT INTO InventoryItems (
          base_item_id, manufacturer_id, brand_id, model_id, serial_no, 
          asset_classification, asset_sub_class, estimated_useful_life
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
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        // Extract serial number from the error detail
        final serialNoMatch =
            RegExp(r'Key \(serial_no\)=\((.+?)\)').firstMatch(e.toString());
        final duplicateSerialNo = serialNoMatch?.group(1) ?? serialNo;
        throw Exception('Serial no. "$duplicateSerialNo" already exists.');
      }
      throw Exception('Error registering inventory item: $e');
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
        null,
        productName,
        0,
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
    int? stockNo,
  }) async {
    await _conn.execute(
      Sql.named('''
      INSERT INTO ProductStocks (product_name_id, product_description_id, stock_no)
      VALUES (@product_name_id, @product_description_id, @stock_no)
    '''),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
        'stock_no': stockNo,
      },
    );
  }

  Future<void> updateStockNo({
    required int productNameId,
    required int productDescriptionId,
    required int newStockNo,
  }) async {
    await _conn.execute(
      Sql.named('''
      UPDATE ProductStocks
      SET stock_no = @stock_no
      WHERE product_name_id = @product_name_id AND product_description_id = @product_description_id;
    '''),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
        'stock_no': newStockNo,
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
  }

  Future<String> registerManufacturer({
    TxSession? ctx,
    required String manufacturerName,
  }) async {
    final conn = ctx ?? _conn;
    final manufacturerId = await _generateUniqueManufacturerId(ctx);

    await conn.execute(
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
    TxSession? ctx,
    required String manufacturerName,
  }) async {
    final conn = ctx ?? _conn;
    final checkIfExists = await conn.execute(
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

  Future<String> registerBrand({
    TxSession? ctx,
    required String brandName,
  }) async {
    final conn = ctx ?? _conn;
    final brandId = await _generateUniqueBrandId(ctx);

    await conn.execute(
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
    TxSession? ctx,
    required String brandName,
  }) async {
    final conn = ctx ?? _conn;
    final checkIfExists = await conn.execute(
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
    TxSession? ctx,
    required String manufacturerId,
    required String brandId,
  }) async {
    final conn = ctx ?? _conn;
    await conn.execute(
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
    TxSession? ctx,
    required String manufacturerId,
    required String brandId,
  }) async {
    final conn = ctx ?? _conn;
    final checkIfExists = await conn.execute(
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
    TxSession? ctx,
    required int productNameId,
    required String brandId,
    required String modelName,
  }) async {
    final conn = ctx ?? _conn;
    final modelId = await _generateUniqueModelId(ctx);

    await conn.execute(
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
    TxSession? ctx,
    required int productNameId,
    required String brandId,
    required String modelName,
  }) async {
    final conn = ctx ?? _conn;
    final checkIfExists = await conn.execute(
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
    TxSession? ctx,
    required String baseItemId,
  }) async {
    final conn = ctx ?? _conn;
    final result = await conn.execute(
      Sql.named(
        '''
        SELECT
          i.*,
          pn.name as product_name,
          pd.description as product_description,
          s.id as supply_id,
          inv.id as inventory_id,
          inv.manufacturer_id,
          inv.brand_id,
          inv.model_id,
          inv.serial_no,
          inv.asset_classification,
          inv.asset_sub_class,
          inv.estimated_useful_life,
          mnf.name as manufacturer_name,
          brnd.name as brand_name,
          md.model_name,
          ps.stock_no
        FROM
          Items i
        LEFT JOIN
          ProductNames pn ON i.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON i.product_description_id = pd.id
        LEFT JOIN
          ProductStocks ps ON i.product_name_id = ps.product_name_id AND i.product_description_id = ps.product_description_id
        LEFT JOIN
          Supplies s ON i.id = s.base_item_id
        LEFT JOIN
          InventoryItems inv ON i.id = inv.base_item_id
        LEFT JOIN
          Manufacturers mnf ON inv.manufacturer_id =  mnf.id
        LEFT JOIN
          Brands brnd ON inv.brand_id = brnd.id
        LEFT JOIN
          Models md ON inv.model_id = md.id
        WHERE
          i.id = @base_item_id;
        ''',
      ),
      parameters: {
        'base_item_id': baseItemId,
      },
    );

    final row = result.first;

    if (row[13] != null) {
      final supplyMap = {
        'supply_id': row[13],
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
        'fund_cluster': row[10],
        'product_name': row[11],
        'product_description': row[12],
        'stock_no': row[25],
      };
      return Supply.fromJson(supplyMap);
    } else if (row[14] != null) {
      final inventoryMap = {
        'inventory_id': row[14],
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
        'fund_cluster': row[10],
        'product_name': row[11],
        'product_description': row[12],
        'manufacturer_id': row[15],
        'brand_id': row[16],
        'model_id': row[17],
        'serial_no': row[18],
        'asset_classification': row[19],
        'asset_sub_class': row[20],
        'estimated_useful_life': row[21],
        'manufacturer_name': row[22],
        'brand_name': row[23],
        'model_name': row[24],
        'stock_no': row[25],
      };
      return InventoryItem.fromJson(inventoryMap);
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
          InventoryItems inv ON i.id = inv.base_item_id
        LEFT JOIN
          Manufacturers mnf ON inv.manufacturer_id =  mnf.id
        LEFT JOIN
          Brands brnd ON inv.brand_id = brnd.id
        LEFT JOIN
          Models md ON inv.model_id = md.id
      ''';

      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
          WHERE (
            i.id ILIKE @search_query OR
            pn.name ILIKE @search_query OR
            pd.description ILIKE @search_query OR
            i.specification ILIKE @search_query OR
            inv.serial_no ILIKE @search_query OR
            md.model_name ILIKE @search_query
          )
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
        whereClause.write('inv.asset_classification = @classification_filter');
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('inv.asset_sub_class = @sub_class_filter');
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND (' : 'WHERE (');
        if (filter == 'supply') {
          whereClause.write('s.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'inventory') {
          whereClause.write('inv.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'out') {
          whereClause.write('i.quantity = 0');
        } else {
          whereClause.write(
              '(s.id IS NOT NULL OR inv.id IS NOT NULL) AND i.quantity > 0');
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
    String? sortBy,
    bool sortAscending = true,
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
          inv.id as inventory_id,
          inv.manufacturer_id,
          inv.brand_id,
          inv.model_id,
          inv.serial_no,
          inv.asset_classification,
          inv.asset_sub_class,
          inv.estimated_useful_life,
          mnf.name as manufacturer_name,
          brnd.name as brand_name,
          md.model_name,
          ps.stock_no
        FROM
          Items i
        LEFT JOIN
          ProductNames pn ON i.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON i.product_description_id = pd.id
        LEFT JOIN
          ProductStocks ps ON i.product_name_id = ps.product_name_id AND i.product_description_id = ps.product_description_id
        LEFT JOIN
          Supplies s ON i.id = s.base_item_id
        LEFT JOIN
          InventoryItems inv ON i.id = inv.base_item_id
        LEFT JOIN
          Manufacturers mnf ON inv.manufacturer_id =  mnf.id
        LEFT JOIN
          Brands brnd ON inv.brand_id = brnd.id
        LEFT JOIN
          Models md ON inv.model_id = md.id
      ''';

      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
          WHERE (
            i.id ILIKE @search_query OR
            pn.name ILIKE @search_query OR
            pd.description ILIKE @search_query OR
            i.specification ILIKE @search_query OR
            inv.serial_no ILIKE @search_query OR
            md.model_name ILIKE @search_query
          )
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
        whereClause.write('inv.asset_classification = @classification_filter');
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('inv.asset_sub_class = @sub_class_filter');
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND (' : 'WHERE (');
        if (filter == 'supply') {
          whereClause.write('s.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'inventory') {
          whereClause.write('inv.id IS NOT NULL AND i.quantity > 0');
        } else if (filter == 'out') {
          whereClause.write('i.quantity = 0');
        } else {
          whereClause.write(
              '(s.id IS NOT NULL OR inv.id IS NOT NULL) AND i.quantity > 0');
        }
        whereClause.write(')');
      }

      final sortDirection = sortAscending ? 'ASC' : 'DESC';

      final finalQuery = '''
      $baseQuery
      $whereClause
      ORDER BY
        ${sortBy ?? 'i.id'} $sortDirection
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
        if (row[13] != null) {
          final supplyMap = {
            'supply_id': row[13],
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
            'fund_cluster': row[10],
            'product_name': row[11],
            'product_description': row[12],
            'stock_no': row[25],
          };
          itemList.add(Supply.fromJson(supplyMap));
        } else if (row[14] != null) {
          final inventoryMap = {
            'inventory_id': row[14],
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
            'fund_cluster': row[10],
            'product_name': row[11],
            'product_description': row[12],
            'manufacturer_id': row[15],
            'brand_id': row[16],
            'model_id': row[17],
            'serial_no': row[18],
            'asset_classification': row[19],
            'asset_sub_class': row[20],
            'estimated_useful_life': row[21],
            'manufacturer_name': row[22],
            'brand_name': row[23],
            'model_name': row[24],
            'stock_no': row[25],
          };
          itemList.add(InventoryItem.fromJson(inventoryMap));
        }
      }
      print('Fetched items for page $page: ${itemList.length}');
      return itemList;
    } catch (e) {
      print('Error fetching items: $e');
      throw Exception('Failed to fetch users.');
    }
  }

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
            inv.id as inventory_id,
            inv.manufacturer_id,
            inv.brand_id,
            inv.model_id,
            inv.serial_no,
            inv.asset_classification,
            inv.asset_sub_class,
            inv.estimated_useful_life,
            mnf.name as manufacturer_name,
            brnd.name as brand_name,
            md.model_name,
            ps.stock_no
          FROM
            Items i
          LEFT JOIN
            ProductNames pn ON i.product_name_id = pn.id
          LEFT JOIN
            ProductDescriptions pd ON i.product_description_id = pd.id
          LEFT JOIN
            ProductStocks ps ON i.product_name_id = ps.product_name_id AND i.product_description_id = ps.product_description_id
          LEFT JOIN
            Supplies s ON i.id = s.base_item_id
          LEFT JOIN
            InventoryItems inv ON i.id = inv.base_item_id
          LEFT JOIN
            Manufacturers mnf ON inv.manufacturer_id =  mnf.id
          LEFT JOIN
            Brands brnd ON inv.brand_id = brnd.id
          LEFT JOIN
            Models md ON inv.model_id = md.id
          WHERE
            i.id = @id;
          ''',
        ),
        parameters: {
          'id': id,
        },
      );

      final row = result.first;

      if (row[13] != null) {
        final supplyMap = {
          'supply_id': row[13],
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
          'fund_cluster': row[10],
          'product_name': row[11],
          'product_description': row[12],
          'stock_no': row[25],
        };
        return Supply.fromJson(supplyMap);
      } else if (row[14] != null) {
        final inventoryMap = {
          'inventory_id': row[14],
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
          'fund_cluster': row[10],
          'product_name': row[11],
          'product_description': row[12],
          'manufacturer_id': row[15],
          'brand_id': row[16],
          'model_id': row[17],
          'serial_no': row[18],
          'asset_classification': row[19],
          'asset_sub_class': row[20],
          'estimated_useful_life': row[21],
          'manufacturer_name': row[22],
          'brand_name': row[23],
          'model_name': row[24],
          'stock_no': row[25],
        };
        return InventoryItem.fromJson(inventoryMap);
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
    int? stockNo,
    String? specification,
    Unit? unit,
    int? quantity,
    double? unitCost,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    int? estimatedUsefulLife,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
  }) async {
    try {
      final List<String> baseItemSetClauses = [];
      final List<String> inventorySetClauses = [];

      final Map<String, dynamic> baseItemParams = {
        'id': id,
      };
      final Map<String, dynamic> inventoryParams = {
        'id': id,
      };

      int? productNameId;
      int? productDescriptionId;
      String? manufacturerId;
      String? brandId;
      String? modelId;

      if (productName != null && productName.isNotEmpty) {
        productNameId = await checkProductNameIfExist(
              productName: productName,
            ) ??
            await registerProductName(
              productName: productName,
            );
      }

      if ((productNameId != null) &&
          (description != null && description.isNotEmpty)) {
        productDescriptionId = await checkProductDescriptionIfExist(
              productDescription: description,
            ) ??
            await registerProductDescription(
              productDescription: description,
            );

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

      if (specification != null && specification.isNotEmpty) {
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
        print('unit cost: $unitCost');
        baseItemSetClauses.add('unit_cost = @unit_cost');
        baseItemParams['unit_cost'] = unitCost;
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        manufacturerId = await checkManufacturerIfExist(
              manufacturerName: manufacturerName,
            ) ??
            await registerManufacturer(
              manufacturerName: manufacturerName,
            );

        inventorySetClauses.add('manufacturer_id = @manufacturer_id');
        inventoryParams['manufacturer_id'] = manufacturerId;
      }

      if ((manufacturerId != null && manufacturerId.isNotEmpty) &&
          (brandName != null && brandName.isNotEmpty)) {
        brandId = await checkBrandIfExist(
              brandName: brandName,
            ) ??
            await registerBrand(
              brandName: brandName,
            );

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

        inventorySetClauses.add('brand_id = @brand_id');
        inventoryParams['brand_id'] = brandId;
      }

      if ((productNameId != null) &&
          (brandId != null && brandId.isNotEmpty) &&
          (modelName != null && modelName.isNotEmpty)) {
        modelId = await checkModelIfExist(
              productNameId: productNameId,
              brandId: brandId,
              modelName: modelName,
            ) ??
            await registerModel(
              productNameId: productNameId,
              brandId: brandId,
              modelName: modelName,
            );

        inventorySetClauses.add('model_id = @model_id');
        inventoryParams['model_id'] = modelId;
      }

      if (serialNo != null && serialNo.isNotEmpty) {
        inventorySetClauses.add('serial_no = @serial_no');
        inventoryParams['serial_no'] = serialNo;
      }

      if (assetClassification != null) {
        inventorySetClauses.add('asset_classification = @asset_classification');
        inventoryParams['asset_classification'] =
            assetClassification.toString().split('.').last;
      }

      if (assetSubClass != null) {
        inventorySetClauses.add('asset_sub_class = @asset_sub_class');
        inventoryParams['asset_sub_class'] =
            assetSubClass.toString().split('.').last;
      }

      if (estimatedUsefulLife != null) {
        inventorySetClauses
            .add('estimated_useful_life = @estimated_useful_life');
        inventoryParams['estimated_useful_life'] = estimatedUsefulLife;
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

      if (inventorySetClauses.isNotEmpty) {
        await _conn.execute(
          Sql.named(
            '''
          UPDATE InventoryItems
          SET ${inventorySetClauses.join(', ')}
          WHERE base_item_id = @id;
          ''',
          ),
          parameters: inventoryParams,
        );
      }

      return true;
    } catch (e) {
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        // Extract serial number from the error detail
        final serialNoMatch =
            RegExp(r'Key \(serial_no\)=\((.+?)\)').firstMatch(e.toString());
        final duplicateSerialNo = serialNoMatch?.group(1) ?? serialNo;
        throw Exception('Serial no. "$duplicateSerialNo" already exists.');
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

  Future<int> getInventoryItemCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT COUNT(*) AS inventory_count FROM InventoryItems;
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
    final result = await _conn.execute(
      Sql.named(
        '''
      WITH weekly_totals AS (
          SELECT
              DATE_TRUNC('week', ia.timestamp) AS week_start,
              CASE 
                  WHEN s.id IS NOT NULL THEN 'Supply'
                  WHEN inv.id IS NOT NULL THEN 'Inventory'
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
              inventoryitems inv ON i.id = inv.base_item_id
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
    var inventoryTrends = <Map<String, dynamic>>[];

    for (var row in result) {
      final trend = {
        'week_start': (row[0] as DateTime).toIso8601String(),
        'item_type': row[1],
        'total_quantity': row[2],
      };
      if (row[1] == 'Supply') {
        supplyTrends.add(trend);
      } else if (row[1] == 'Inventory') {
        inventoryTrends.add(trend);
      }
    }

    // Calculate percentage change for Supply and Equipment separately
    double supplyPercentageChange = 0;
    double inventoryPercentageChange = 0;

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

    if (inventoryTrends.length > 1) {
      final currentWeekEquipment =
          (inventoryTrends[0]['total_quantity'] as int?) ?? 0;
      final previousWeekEquipment =
          (inventoryTrends[1]['total_quantity'] as int?) ?? 0;
      inventoryPercentageChange = previousWeekEquipment == 0
          ? 0
          : ((currentWeekEquipment - previousWeekEquipment) /
                  previousWeekEquipment) *
              100;
      inventoryPercentageChange =
          double.parse(inventoryPercentageChange.toStringAsFixed(2));
    }

    return {
      'supply_trends': supplyTrends,
      'inventory_trends': inventoryTrends,
      'supply_percentage_change': supplyPercentageChange,
      'inventory_percentage_change': inventoryPercentageChange,
    };
  }

  Future<List<Map<String, dynamic>>> getInventoryStockLevels() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT
            CASE
                WHEN s.id IS NOT NULL THEN 'Supply'
                WHEN inv.id IS NOT NULL THEN 'Inventory'
                ELSE 'Unknown'
            END AS item_type,
            COUNT(i.id) AS item_count,
            SUM(COALESCE(i.quantity, 0)) AS total_stock
        FROM
            items i
        LEFT JOIN
            supplies s ON i.id = s.base_item_id
        LEFT JOIN
            inventoryitems inv ON i.id = inv.base_item_id
        GROUP BY
            CASE
                WHEN s.id IS NOT NULL THEN 'Supply'
                WHEN inv.id IS NOT NULL THEN 'Inventory'
                ELSE 'Unknown'
            END;
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
    TxSession? ctx,
    required String baseItemId,
    required InventoryActivity action,
    required int quantity,
  }) async {
    try {
      final conn = ctx ?? _conn;
      final result = await conn.execute(
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
