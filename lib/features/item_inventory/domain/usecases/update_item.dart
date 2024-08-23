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
      specification: params.specification,
      brand: params.brand,
      model: params.model,
      serialNo: params.serialNo,
      manufacturer: params.manufacturer,
      assetClassification:  params.assetClassification,
      assetSubClass: params.assetSubClass,
      unit: params.unit,
      quantity: params.quantity,
      unitCost: params.unitCost,
      estimatedUsefulLife: params.estimatedUsefulLife,
      acquiredDate: params.acquiredDate,
    );
  }
}

class UpdateItemParams {
  const UpdateItemParams({
    required this.id,
    this.itemName,
    this.description,
    this.specification,
    this.brand,
    this.model,
    this.serialNo,
    this.manufacturer,
    this.assetClassification,
    this.assetSubClass,
    this.unit,
    this.quantity,
    this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
  });

  final int id;
  final String? itemName;
  final String? description;
  final String? specification;
  final String? brand;
  final String? model;
  final String? serialNo;
  final String? manufacturer;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit? unit;
  final int? quantity;
  final double? unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
}
