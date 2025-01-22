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
    required super.unitCost,
    super.estimatedUsefulLife,
    super.acquiredDate,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
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

    final shareableItemInformation = ShareableItemInformationModel.fromJson(
        json['shareable_item_information']);

    final manufacturerBrand =
        ManufacturerBrandModel.fromJson(json['manufacturer_brand']);

    final model = Model.fromJson(json['model']);

    return EquipmentModel(
      id: json['equipment_id'] as int,
      productStockEntity: productStock,
      shareableItemInformationEntity: shareableItemInformation,
      manufacturerBrandEntity: manufacturerBrand,
      modelEntity: model,
      serialNo: json['serial_no'] as String,
      assetClassification: assetClassification,
      assetSubClass: assetSubClass,
      unitCost: json['unit_cost'] is String
          ? double.tryParse(json['unit_cost'] as String) ?? 0.0
          : json['unit_cost'] as double,
      estimatedUsefulLife: json['estimated_useful_life'] as int?,
      acquiredDate: json['acquired_date'] != null
          ? json['acquired_date'] is String
              ? DateTime.parse(json['acquired_date'] as String)
              : json['acquired_date'] as DateTime
          : null,
    );
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
      'unit_cost': unitCost,
      'estimated_useful_life': estimatedUsefulLife,
      'acquired_date': acquiredDate?.toIso8601String(),
    };
  }
}
