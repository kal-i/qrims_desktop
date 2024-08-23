import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/error/failure.dart';
import '../entities/item_with_stock.dart';
import '../entities/paginated_item_name.dart';
import '../entities/paginated_item_result.dart';
import '../entities/stock.dart';
import '../../../../core/enums/unit.dart' as unit;

abstract interface class ItemInventoryRepository {
  Future<Either<Failure, PaginatedItemResultEntity>> getItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  });

  Future<Either<Failure, ItemWithStockEntity>> registerItem({
    required String itemName,
    required String description,
    required String specification,
    required String brand,
    required String model,
    String? serialNo,
    required String manufacturer,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required unit.Unit unit,
    required int quantity,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  });

  Future<Either<Failure, ItemWithStockEntity?>> getItemById({
    required int id,
  });

  Future<Either<Failure, bool>> updateItem({
    required int id,
    String? itemName,
    String? description,
    String? specification,
    String? brand,
    String? model,
    String? serialNo,
    String? manufacturer,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    unit.Unit? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  });

  Future<Either<Failure, List<StockEntity>?>> getStocks();

  Future<Either<Failure, List<String>?>> getStocksProductName({
    String? productName,
  });

  Future<Either<Failure, PaginatedItemNameEntity>> getPaginatedProductNames({
    int? page,
    int? pageSize,
    String? productName,
  });

  Future<Either<Failure, List<String>?>> getStocksDescription({
    required String productName,
  });

  Future<Either<Failure, StockEntity?>> getStockById({
    required int id,
  });
}
