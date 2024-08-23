import 'package:equatable/equatable.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';

class ItemEntity extends Equatable {
  const ItemEntity({
    required this.id,
    required this.specification,
    required this.brand,
    required this.model,
    this.serialNo,
    required this.manufacturer,
    this.assetClassification,
    this.assetSubClass,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
    required this.encryptedId,
    required this.qrCodeImageData,
    this.stockId,
  });

  final int id;
  final String specification;
  final String brand;
  final String model;
  final String? serialNo;
  final String manufacturer;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
  final String encryptedId;
  final String qrCodeImageData;
  final int? stockId;

  @override
  List<Object?> get props => [
        id,
        specification,
        brand,
        serialNo,
        manufacturer,
        assetClassification,
        assetSubClass,
        unit,
        quantity,
        unitCost,
        estimatedUsefulLife,
        acquiredDate,
        encryptedId,
        qrCodeImageData,
        stockId,
      ];
}
