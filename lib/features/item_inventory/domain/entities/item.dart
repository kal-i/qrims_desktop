import 'package:equatable/equatable.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';

class ItemEntity extends Equatable {
  const ItemEntity({
    required this.id,
    required this.productNameId,
    required this.productDescriptionId,
    required this.manufacturerId,
    required this.brandId,
    required this.modelId,
    this.serialNo,
    required this.specification,
    this.assetClassification,
    this.assetSubClass,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
    required this.encryptedId,
    required this.qrCodeImageData,
  });

  final String id;
  final String productNameId;
  final String productDescriptionId;
  final String manufacturerId;
  final String brandId;
  final String modelId;
  final String? serialNo;
  final String specification;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
  final String encryptedId;
  final String qrCodeImageData;

  @override
  List<Object?> get props => [
        id,
        productNameId,
        productDescriptionId,
        manufacturerId,
        brandId,
        modelId,
        serialNo,
        specification,
        assetClassification,
        assetSubClass,
        unit,
        quantity,
        unitCost,
        estimatedUsefulLife,
        acquiredDate,
        encryptedId,
        qrCodeImageData,
      ];
}
