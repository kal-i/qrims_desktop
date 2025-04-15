import 'package:fpdart/src/either.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/item_inventory_repository.dart';

class UpdateItem implements UseCase<bool, UpdateItemParams> {
  const UpdateItem({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateItemParams params) async {
    return await itemInventoryRepository.updateItem(
      id: params.id,
      itemName: params.itemName,
      description: params.description,
      manufacturerName: params.manufacturerName,
      brandName: params.brandName,
      modelName: params.modelName,
      serialNo: params.serialNo,
      specification: params.specification,
      assetClassification: params.assetClassification,
      assetSubClass: params.assetSubClass,
      unit: params.unit,
      quantity: params.quantity,
      unitCost: params.unitCost,
      estimatedUsefulLife: params.estimatedUsefulLife,
    );
  }
}

class UpdateItemParams {
  const UpdateItemParams({
    required this.id,
    this.itemName,
    this.description,
    this.manufacturerName,
    this.brandName,
    this.modelName,
    this.serialNo,
    this.specification,
    this.assetClassification,
    this.assetSubClass,
    this.unit,
    this.quantity,
    this.unitCost,
    this.estimatedUsefulLife,
  });

  final String id;
  final String? itemName;
  final String? description;
  final String? manufacturerName;
  final String? brandName;
  final String? modelName;
  final String? serialNo;
  final String? specification;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit? unit;
  final int? quantity;
  final double? unitCost;
  final int? estimatedUsefulLife;
}
