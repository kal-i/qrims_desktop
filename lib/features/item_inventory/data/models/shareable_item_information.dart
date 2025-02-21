import '../../../../core/enums/unit.dart';
import '../../domain/entities/shareable_item_information.dart';

class ShareableItemInformationModel extends ShareableItemInformationEntity {
  const ShareableItemInformationModel({
    required super.id,
    required super.productNameId,
    required super.productDescriptionId,
    required super.specification,
    required super.unit,
    required super.quantity,
    required super.unitCost,
    required super.encryptedId,
    required super.qrCodeImageData,
    super.acquiredDate,
  });

  factory ShareableItemInformationModel.fromJson(Map<String, dynamic> json) {
    final unit = Unit.values.firstWhere(
      (e) => e.toString().split('.').last == json['unit'] as String,
      orElse: () => Unit.undetermined,
    );

    return ShareableItemInformationModel(
      id: json['base_item_id'] as String,
      productNameId: json['product_name_id'] as String,
      productDescriptionId: json['product_description_id'] as String,
      specification: json['specification'] as String,
      unit: unit,
      quantity: json['quantity'] as int,
      unitCost: json['unit_cost'] is String
          ? double.tryParse(json['unit_cost'] as String) ?? 0.0
          : json['unit_cost'] as double,
      encryptedId: json['encrypted_id'] as String,
      qrCodeImageData: json['qr_code_image_data'] as String,
      acquiredDate: json['acquired_date'] != null
          ? json['acquired_date'] is String
              ? DateTime.parse(json['acquired_date'] as String)
              : json['acquired_date'] as DateTime
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_item_id': id,
      'product_name_id': productNameId,
      'product_description': productDescriptionId,
      'specification': specification,
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'unit_cost': unitCost,
      'encrypted_id': encryptedId,
      'qr_code_image_data': qrCodeImageData,
      'acquired_date': acquiredDate?.toIso8601String(),
    };
  }
}
