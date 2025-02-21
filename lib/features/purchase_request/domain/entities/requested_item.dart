import '../../../../core/enums/fulfillment_status.dart';
import '../../../../core/enums/unit.dart';
import '../../../item_inventory/domain/entities/product_description.dart';
import '../../../item_inventory/domain/entities/product_name.dart';

class RequestedItemEntity {
  const RequestedItemEntity({
    required this.id,
    required this.prId,
    required this.productNameEntity,
    required this.productDescriptionEntity,
    this.specification,
    required this.unit,
    required this.quantity,
    required this.remainingQuantity,
    required this.unitCost,
    required this.totalCost,
    this.status = FulfillmentStatus.notFulfilled,
  });

  final int id;
  final String prId;
  final ProductNameEntity productNameEntity;
  final ProductDescriptionEntity productDescriptionEntity;
  final String? specification;
  final Unit unit;
  final int quantity;
  final int? remainingQuantity;
  final double unitCost;
  final double totalCost;
  final FulfillmentStatus? status;
}
