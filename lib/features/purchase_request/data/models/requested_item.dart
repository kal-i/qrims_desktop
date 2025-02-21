import '../../../../core/enums/fulfillment_status.dart';
import '../../../../core/enums/unit.dart';
import '../../../item_inventory/data/models/product_description.dart';
import '../../../item_inventory/data/models/product_name.dart';
import '../../domain/entities/requested_item.dart';

class RequestedItemModel extends RequestedItemEntity {
  const RequestedItemModel({
    required super.id,
    required super.prId,
    required super.productNameEntity,
    required super.productDescriptionEntity,
    super.specification,
    required super.unit,
    required super.quantity,
    required super.remainingQuantity,
    required super.unitCost,
    required super.totalCost,
    super.status,
  });

  factory RequestedItemModel.fromJson(Map<String, dynamic> json) {
    final unitString = json['unit'] as String;
    final fulfillmentStatusString = json['status'] as String;

    final unit = Unit.values.firstWhere(
      (e) => e.toString().split('.').last == unitString,
    );

    final status = FulfillmentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == fulfillmentStatusString,
    );

    final productName = ProductNameModel.fromJson(json['product_name']);

    final productDescription =
        ProductDescriptionModel.fromJson(json['product_description']);

    return RequestedItemModel(
      id: json['id'] as int,
      prId: json['pr_id'] as String,
      productNameEntity: productName,
      productDescriptionEntity: productDescription,
      specification: json['specification'],
      unit: unit,
      quantity: json['quantity'] as int,
      remainingQuantity: json['remaining_quantity'] as int? ?? 0,
      unitCost: json['unit_cost'] is String
          ? double.parse(json['unit_cost'] as String)
          : json['unit_cost'] as double,
      totalCost: json['total_cost'] is String
          ? double.parse(json['total_cost'] as String)
          : json['total_cost'] as double,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pr_id': prId,
      'product_name': (productNameEntity as ProductNameModel).toJson(),
      'product_description':
          (productDescriptionEntity as ProductDescriptionModel).toJson(),
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'remaining_quantity': remainingQuantity,
      'unit_cost': unitCost,
      'total_cost': totalCost,
    };
  }
}
