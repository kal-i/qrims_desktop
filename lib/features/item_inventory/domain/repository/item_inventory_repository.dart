import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/error/failure.dart';
import '../entities/base_item.dart';
import '../entities/paginated_item_result.dart';
import '../../../../core/enums/unit.dart' as unit;

abstract interface class ItemInventoryRepository {
  Future<Either<Failure, PaginatedItemResultEntity>> getItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? filter,
    String? sortBy,
    bool? sortAscending,
    String? manufacturerName,
    String? brandName,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  });

  Future<Either<Failure, BaseItemEntity>> registerSupplyItem({
    FundCluster? fundCluster,
    required String itemName,
    required String description,
    String? specification,
    required unit.Unit unit,
    required int quantity,
    required double unitCost,
    DateTime? acquiredDate,
  });

  Future<Either<Failure, List<BaseItemEntity>>> registerInventoryItem({
    FundCluster? fundCluster,
    required String itemName,
    required String description,
    String? specification,
    required unit.Unit unit,
    required int quantity,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    List<String>? serialNos,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  });

  Future<Either<Failure, BaseItemEntity?>> getItemById({
    required String id,
  });

  Future<Either<Failure, bool>> updateItem({
    required String id,
    String? itemName,
    String? description,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
    String? specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    unit.Unit? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  });
}
