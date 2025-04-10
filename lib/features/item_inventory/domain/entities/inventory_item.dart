import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import 'base_item.dart';
import 'manufacturer_brand.dart';
import 'model.dart';

class InventoryItemEntity extends BaseItemEntity {
  const InventoryItemEntity({
    required this.id,
    required super.productStockEntity,
    required super.shareableItemInformationEntity,
    this.manufacturerBrandEntity,
    this.modelEntity,
    this.serialNo,
    this.assetClassification,
    this.assetSubClass,
    this.estimatedUsefulLife = 1,
  });

  final int id;
  final ManufacturerBrandEntity? manufacturerBrandEntity;
  final ModelEntity? modelEntity;
  final String? serialNo;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final int? estimatedUsefulLife;
}
