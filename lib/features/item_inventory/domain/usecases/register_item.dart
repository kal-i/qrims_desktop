import 'package:fpdart/src/either.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/item_with_stock.dart';
import '../repository/item_inventory_repository.dart';

class RegisterItem implements UseCase<ItemWithStockEntity, RegisterItemParams> {
  const RegisterItem({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, ItemWithStockEntity>> call(RegisterItemParams params) async {
    return await itemInventoryRepository.registerItem(
      specification: params.specification,
      itemName: params.itemName,
      manufacturerName: params.manufacturerName,
      brandName: params.brandName,
      modelName: params.modelName,
      serialNo: params.serialNo,
      description: params.description,
      assetClassification: params.assetClassification,
      assetSubClass: params.assetSubClass,
      unit: params.unit,
      quantity: params.quantity,
      unitCost: params.unitCost,
      estimatedUsefulLife: params.estimatedUsefulLife,
      acquiredDate: params.acquiredDate,
    );
  }
}

class RegisterItemParams {
  const RegisterItemParams({
    required this.itemName,
    required this.description,
    required this.manufacturerName,
    required this.brandName,
    required this.modelName,
    this.serialNo,
    required this.specification,
    this.assetClassification,
    this.assetSubClass,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
  });

  final String itemName;
  final String description;
  final String manufacturerName;
  final String brandName;
  final String modelName;
  final String? serialNo;
  final String specification;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
}
