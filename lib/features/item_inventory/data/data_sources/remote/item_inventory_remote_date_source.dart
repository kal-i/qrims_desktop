import '../../../../../core/enums/asset_classification.dart';
import '../../../../../core/enums/asset_sub_class.dart';
import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/unit.dart';
import '../../models/base_item.dart';
import '../../models/paginated_item_result.dart';

abstract interface class ItemInventoryRemoteDateSource {
  Future<PaginatedItemResultModel> getItems({
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

  Future<BaseItemModel> registerSupplyItem({
    FundCluster? fundCluster,
    required String itemName,
    required String description,
    String? specification,
    required Unit unit,
    required int quantity,
    required double unitCost,
    DateTime? acquiredDate,
  });

  Future<List<BaseItemModel>> registerInventoryItem({
    FundCluster? fundCluster,
    required String itemName,
    required String description,
    String? specification,
    required Unit unit,
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

  Future<BaseItemModel?> getItemById({
    required String id,
  });

  Future<bool> updateItem({
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
    Unit? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
  });

  Future<bool> manageStock({
    required String itemName,
    required String description,
    required int stockNo,
  });
}
