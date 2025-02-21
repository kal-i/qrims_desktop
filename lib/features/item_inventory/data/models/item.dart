import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';
import '../../domain/entities/item.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.productNameId,
    required super.productDescriptionId,
    required super.manufacturerId,
    required super.brandId,
    required super.modelId,
    super.serialNo,
    required super.specification,
    super.assetClassification,
    super.assetSubClass,
    required super.unit,
    required super.quantity,
    required super.unitCost,
    super.estimatedUsefulLife,
    super.acquiredDate,
    required super.encryptedId,
    required super.qrCodeImageData,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
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

    final unit = Unit.values.firstWhere(
      (e) =>
          e.toString().split('.').last ==
          json['unit'], // Provide a default value if necessary
      orElse: () => Unit.undetermined,
    );

    return ItemModel(
      id: json['item_id'] as String? ?? '',
      productNameId: json['product_name_id'] as String? ?? '',
      productDescriptionId: json['product_description_id'] as String? ?? '',
      manufacturerId: json['manufacturer_id'] as String? ?? '',
      brandId: json['brand_id'] as String? ?? '',
      modelId: json['model_id'] as String? ?? '',
      serialNo: json['serial_no'] as String? ?? '',
      specification: json['specification'] as String? ?? '',
      assetClassification: assetClassification,
      assetSubClass: assetSubClass,
      unit: unit,
      quantity: json['quantity'] as int? ?? 0,
      unitCost: json['unit_cost'] is String
          ? double.tryParse(json['unit_cost'] as String) ?? 0.0
          : json['unit_cost'] as double? ?? 0.0,
      estimatedUsefulLife: json['estimated_useful_life'] as int? ?? 0,
      acquiredDate: json['acquired_date'] != null
          ? json['acquired_date'] is String
              ? DateTime.parse(json['acquired_date'] as String)
              : json['acquired_date'] as DateTime
          : null,
      encryptedId: json['encrypted_id'] as String? ?? '',
      qrCodeImageData: json['qr_code_image_data'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'product_name_id': productNameId,
      'product_description_id': productDescriptionId,
      'manufacturer_id': manufacturerId,
      'brand_id': brandId,
      'model_id': modelId,
      'serial_no': serialNo,
      'specification': specification,
      'asset_classification': assetClassification.toString().split('.').last,
      'asset_sub_class': assetSubClass.toString().split('.').last,
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'unit_cost': unitCost,
      'estimated_useful_life': estimatedUsefulLife,
      'acquired_date': acquiredDate?.toIso8601String(),
      'encrypted_id': encryptedId,
      'qr_code_image_data': qrCodeImageData,
    };
  }

  @override
  List<Object?> get props => [
        super.props,
      ];
}
