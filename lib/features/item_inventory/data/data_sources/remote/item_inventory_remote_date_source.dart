import '../../../../../core/enums/asset_classification.dart';
import '../../../../../core/enums/asset_sub_class.dart';
import '../../../../../core/enums/unit.dart';
import '../../models/item_with_stock.dart';
import '../../models/paginated_item_name.dart';
import '../../models/paginated_item_result.dart';
import '../../models/stock.dart';

abstract interface class ItemInventoryRemoteDateSource {
  Future<PaginatedItemResultModel> getItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  });

  Future<ItemWithStockModel> registerItem({
    required String itemName,
    required String description,
    required String specification,
    required String brand,
    required String model,
    String? serialNo,
    required String manufacturer,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required Unit unit,
    required int quantity,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  });

  Future<ItemWithStockModel?> getItemById({
    required int id,
  });

  Future<bool> updateItem({
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
    Unit? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  });

  Future<List<StockModel>?> getStocks();

  Future<List<String>?> getStocksProductName({
    String? productName,
  });

  Future<PaginatedItemNameModel> getPaginatedProductNames({
    int? page,
    int? pageSize,
    String? productName,
  });

  Future<List<String>?> getStocksDescription({
    required String productName,
  });

  Future<StockModel?> getStockById({
    required int id,
  });
}
