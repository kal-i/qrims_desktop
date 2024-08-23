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
    String? sortBy,
    bool? sortAscending,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.getItems(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortAscending: sortAscending,
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
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.registerItem(
        itemName: itemName,
        description: description,
        specification: specification,
        brand: brand,
        model: model,
        serialNo: serialNo,
        manufacturer: manufacturer,
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
    required int id,
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
  Future<Either<Failure, List<StockEntity>?>> getStocks() async {
    try {
      final response = await itemInventoryRemoteDateSource.getStocks();

      print('get stock repo res: $response');
      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
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
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.updateItem(
        id: id,
        itemName: itemName,
        description: description,
        specification: specification,
        brand: brand,
        model: model,
        serialNo: serialNo,
        manufacturer: manufacturer,
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

  @override
  Future<Either<Failure, StockEntity?>> getStockById({
    required int id,
  }) {
    // TODO: implement getStockById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<String>?>> getStocksProductName({
    String? productName,
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.getStocksProductName(
        productName: productName,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PaginatedItemNameEntity>> getPaginatedProductNames({
    int? page,
    int? pageSize,
    String? productName,
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.getPaginatedProductNames(
        page: page,
        pageSize: pageSize,
        productName: productName,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>?>> getStocksDescription({
    required String productName,
  }) async {
    try {
      final response = await itemInventoryRemoteDateSource.getStocksDescription(
        productName: productName,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
