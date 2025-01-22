import '../../domain/entities/supply.dart';
import 'base_item.dart';
import 'product_stock.dart';
import 'shareable_item_information.dart';

class SupplyModel extends SupplyEntity implements BaseItemModel {
  const SupplyModel({
    required super.id,
    required super.productStockEntity,
    required super.shareableItemInformationEntity,
  });

  factory SupplyModel.fromJson(Map<String, dynamic> json) {
    final productStock = ProductStockModel.fromJson(json['product_stock']);
    final shareableItemInformation = ShareableItemInformationModel.fromJson(
        json['shareable_item_information']);

    return SupplyModel(
      id: json['supply_id'] as int,
      productStockEntity: productStock,
      shareableItemInformationEntity: shareableItemInformation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supply_id': id,
      'product_stock': (productStockEntity as ProductStockModel).toJson(),
      'shareable_item_information':
          (shareableItemInformationEntity as ShareableItemInformationModel)
              .toJson(),
    };
  }
}
