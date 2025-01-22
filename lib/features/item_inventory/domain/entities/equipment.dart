import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import 'base_item.dart';
import 'manufacturer_brand.dart';
import 'model.dart';

class EquipmentEntity extends BaseItemEntity {
  const EquipmentEntity({
    required this.id,
    required super.productStockEntity,
    required super.shareableItemInformationEntity,
    required this.manufacturerBrandEntity,
    required this.modelEntity,
    required this.serialNo,
    required this.assetClassification,
    required this.assetSubClass,
    required this.unitCost,
    this.estimatedUsefulLife = 1,
    this.acquiredDate,
  });

  final int id;
  final ManufacturerBrandEntity manufacturerBrandEntity;
  final ModelEntity modelEntity;
  final String serialNo;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
}
