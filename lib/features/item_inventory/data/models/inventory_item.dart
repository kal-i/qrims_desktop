import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../domain/entities/inventory_item.dart';
import 'base_item.dart';
import 'manufacturer_brand.dart';
import 'model.dart';
import 'product_stock.dart';
import 'shareable_item_information.dart';

class InventoryItemModel extends InventoryItemEntity implements BaseItemModel {
  const InventoryItemModel({
    required super.id,
    required super.productStockEntity,
    required super.shareableItemInformationEntity,
    super.manufacturerBrandEntity,
    super.modelEntity,
    super.serialNo,
    super.assetClassification,
    super.assetSubClass,
    super.estimatedUsefulLife,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    print('received json by inventory: $json');

    final assetClassification = (json['asset_classification'] as String?) !=
            null
        ? AssetClassification.values.firstWhere(
            (e) => e.toString().split('.').last == json['asset_classification'],
            orElse: () => AssetClassification.unknown,
          )
        : null;

    final assetSubClass = (json['asset_sub_class'] as String?) != null
        ? AssetSubClass.values.firstWhere(
            (e) => e.toString().split('.').last == json['asset_sub_class'],
            orElse: () => AssetSubClass.unknown,
          )
        : null;

    final productStock = ProductStockModel.fromJson(json['product_stock']);
    print('product stock converted');

    final shareableItemInformation = ShareableItemInformationModel.fromJson(
        json['shareable_item_information']);
    print('shareable item  info converted');

    final manufacturerBrand = json['manufacturer_brand'] != null
        ? ManufacturerBrandModel.fromJson(json['manufacturer_brand'])
        : null;
    print('manufacturer brand item  info converted');

    final model = json['model'] != null ? Model.fromJson(json['model']) : null;
    print('model  info converted');

    final inventoryItem = InventoryItemModel(
      id: json['inventory_id'] as int,
      productStockEntity: productStock,
      shareableItemInformationEntity: shareableItemInformation,
      manufacturerBrandEntity: manufacturerBrand,
      modelEntity: model,
      serialNo: json['serial_no'] as String?,
      assetClassification: assetClassification,
      assetSubClass: assetSubClass,
      estimatedUsefulLife: json['estimated_useful_life'] as int?,
    );
    print('inventory converted');
    return inventoryItem;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'inventory_id': id,
      'product_stock': (productStockEntity as ProductStockModel).toJson(),
      'shareable_item_information':
          (shareableItemInformationEntity as ShareableItemInformationModel)
              .toJson(),
      'manufacturer_brand':
          (manufacturerBrandEntity as ManufacturerBrandModel?)?.toJson(),
      'model': (modelEntity as Model?)?.toJson(),
      'serial_no': serialNo,
      'asset_classification': assetClassification.toString().split('.').last,
      'asset_sub_class': assetSubClass.toString().split('.').last,
      'estimated_useful_life': estimatedUsefulLife,
    };
  }
}
