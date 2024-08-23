import 'dart:ffi';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';
import '../../domain/entities/item.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.specification,
    required super.brand,
    required super.model,
    super.serialNo,
    required super.manufacturer,
    super.assetClassification,
    super.assetSubClass,
    required super.unit,
    required super.quantity,
    required super.unitCost,
    super.estimatedUsefulLife,
    super.acquiredDate,
    required super.encryptedId,
    required super.qrCodeImageData,
    super.stockId,
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
          (e) => e.toString().split('.').last == json['unit'], // Provide a default value if necessary
      orElse: () => Unit.undetermined,
    );

    return ItemModel(
      id: json['item_id'] as int? ?? 0,
      specification: json['specification'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      serialNo: json['serial_no'] as String? ?? '',
      manufacturer: json['manufacturer'] as String? ?? '',
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
      stockId: json['stock_id'] as int?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'specification': specification,
      'brand': brand,
      'model': model,
      'serial_no': serialNo,
      'manufacturer': manufacturer,
      'asset_classification': assetClassification.toString().split('.').last,
      'asset_sub_class': assetSubClass.toString().split('.').last,
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'unit_cost': unitCost,
      'estimated_useful_life': estimatedUsefulLife,
      'acquired_date': acquiredDate?.toIso8601String(),
      'encrypted_id': encryptedId,
      'qr_code_image_data': qrCodeImageData,
      'stock_id': stockId,
    };
  }

  @override
  List<Object?> get props => [
        super.props,
      ];
}
