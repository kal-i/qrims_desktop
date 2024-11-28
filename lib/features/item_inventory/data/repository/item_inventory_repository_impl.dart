import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/item_with_stock.dart';
import '../../domain/entities/paginated_item_name.dart';
import '../../domain/entities/paginated_item_result.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/stock.dart';
import '../../domain/repository/item_inventory_repository.dart';
import '../data_sources/remote/item_inventory_remote_date_source.dart';
import '../../../../core/enums/unit.dart' as unit;

class ItemInventoryRepositoryImpl implements ItemInventoryRepository {
  const ItemInventoryRepositoryImpl({
    required this.itemInventoryRemoteDateSource,
  });

  final ItemInventoryRemoteDateSource itemInventoryRemoteDateSource;

  @override
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
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.getItems(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        filter: filter,
        sortBy: sortBy,
        sortAscending: sortAscending,
        manufacturerName: manufacturerName,
        brandName: brandName,
        classificationFilter: classificationFilter,
        subClassFilter: subClassFilter,
      );

      print(response);

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ItemWithStockEntity>>> registerItem({
    required String itemName,
    required String description,
    required String manufacturerName,
    required String brandName,
    required String modelName,
    String? serialNo,
    required String specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required unit.Unit unit,
    required int quantity,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.registerItem(
        itemName: itemName,
        description: description,
        manufacturerName: manufacturerName,
        brandName: brandName,
        modelName: modelName,
        serialNo: serialNo,
        specification: specification,
        assetClassification: assetClassification,
        assetSubClass: assetSubClass,
        unit: unit,
        quantity: quantity,
        unitCost: unitCost,
        estimatedUsefulLife: estimatedUsefulLife,
        acquiredDate: acquiredDate,
      );

      print(response);
      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ItemWithStockEntity?>> getItemById({
    required String id,
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.getItemById(
        id: id,
      );

      print('get item by id repo res: $response');
      return right(response);
    } on ServerException catch (e) {
      print('get item by id repo err: $e');
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateItem({
    required String id,
    String? itemName,
    String? description,
    String? specification,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    unit.Unit? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.updateItem(
        id: id,
        itemName: itemName,
        description: description,
        manufacturerName: manufacturerName,
        brandName: brandName,
        modelName: modelName,
        serialNo: serialNo,
        specification: specification,
        assetClassification: assetClassification,
        assetSubClass: assetSubClass,
        quantity: quantity,
        unit: unit,
        unitCost: unitCost,
        estimatedUsefulLife: estimatedUsefulLife,
        acquiredDate: acquiredDate,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
