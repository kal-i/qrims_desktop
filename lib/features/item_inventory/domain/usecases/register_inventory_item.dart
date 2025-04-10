import 'package:fpdart/src/either.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/base_item.dart';
import '../repository/item_inventory_repository.dart';

class RegisterInventoryItem
    implements UseCase<List<BaseItemEntity>, RegisterEquipmentItemParams> {
  const RegisterInventoryItem({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, List<BaseItemEntity>>> call(
    RegisterEquipmentItemParams params,
  ) async {
    return await itemInventoryRepository.registerInventoryItem(
      fundCluster: params.fundCluster,
      itemName: params.itemName,
      description: params.description,
      specification: params.specification,
      unit: params.unit,
      quantity: params.quantity,
      manufacturerName: params.manufacturerName,
      brandName: params.brandName,
      modelName: params.modelName,
      serialNo: params.serialNo,
      assetClassification: params.assetClassification,
      assetSubClass: params.assetSubClass,
      unitCost: params.unitCost,
      estimatedUsefulLife: params.estimatedUsefulLife,
      acquiredDate: params.acquiredDate,
    );
  }
}

class RegisterEquipmentItemParams {
  const RegisterEquipmentItemParams({
    this.fundCluster,
    required this.itemName,
    required this.description,
    this.specification,
    required this.unit,
    required this.quantity,
    this.manufacturerName,
    this.brandName,
    this.modelName,
    this.serialNo,
    this.assetClassification,
    this.assetSubClass,
    required this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
  });

  final FundCluster? fundCluster;
  final String itemName;
  final String description;
  final String? specification;
  final Unit unit;
  final int quantity;
  final String? manufacturerName;
  final String? brandName;
  final String? modelName;
  final String? serialNo;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
}
