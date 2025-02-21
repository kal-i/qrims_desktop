import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../domain/entities/equipment.dart';
import 'base_item.dart';
import 'manufacturer_brand.dart';
import 'model.dart';
import 'product_stock.dart';
import 'shareable_item_information.dart';

class EquipmentModel extends EquipmentEntity implements BaseItemModel {
  const EquipmentModel({
    required super.id,
    required super.productStockEntity,
    required super.shareableItemInformationEntity,
    required super.manufacturerBrandEntity,
    required super.modelEntity,
    required super.serialNo,
    required super.assetClassification,
    required super.assetSubClass,
    super.estimatedUsefulLife,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    print('received json by equipment: $json');
    final assetClassificationString = json['asset_classification'] as String?;
    final assetSubClassString = json['asset_sub_class'] as String?;

    final assetClassification = assetClassificationString != null
        ? AssetClassification.values.firstWhere(
            (e) => e.toString().split('.').last == assetClassificationString,
            orElse: () => AssetClassification.unknown,
          )
        : AssetClassification.unknown;

    final assetSubClass = assetSubClassString != null
        ? AssetSubClass.values.firstWhere(
            (e) => e.toString().split('.').last == assetSubClassString,
            orElse: () => AssetSubClass.unknown,
          )
        : AssetSubClass.unknown;

    final productStock = ProductStockModel.fromJson(json['product_stock']);
    print('product stock converted');

    final shareableItemInformation = ShareableItemInformationModel.fromJson(
        json['shareable_item_information']);
    print('shareable item  info converted');

    final manufacturerBrand =
        ManufacturerBrandModel.fromJson(json['manufacturer_brand']);
    print('manufacturer brand item  info converted');

    final model = Model.fromJson(json['model']);
    print('model  info converted');
    print('${json['equipment_id']}');

    final equipment = EquipmentModel(
      id: json['equipment_id'] as int,
      productStockEntity: productStock,
      shareableItemInformationEntity: shareableItemInformation,
      manufacturerBrandEntity: manufacturerBrand,
      modelEntity: model,
      serialNo: json['serial_no'] as String,
      assetClassification: assetClassification,
      assetSubClass: assetSubClass,
      estimatedUsefulLife: json['estimated_useful_life'] as int?,
    );
    print('equipment converted');
    return equipment;
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment_id': id,
      'product_stock': (productStockEntity as ProductStockModel).toJson(),
      'shareable_item_information':
          (shareableItemInformationEntity as ShareableItemInformationModel)
              .toJson(),
      'manufacturer_brand':
          (manufacturerBrandEntity as ManufacturerBrandModel).toJson(),
      'model': (modelEntity as Model).toJson(),
      'serial_no': serialNo,
      'asset_classification': assetClassification.toString().split('.').last,
      'asset_sub_class': assetSubClass.toString().split('.').last,
      'estimated_useful_life': estimatedUsefulLife,
    };
  }
}
