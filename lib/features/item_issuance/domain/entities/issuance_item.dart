import '../../../item_inventory/domain/entities/base_item.dart';

class IssuanceItemEntity {
  const IssuanceItemEntity({
    required this.issuanceId,
    required this.itemEntity,
    required this.quantity,
  });

  final String issuanceId;
  final BaseItemEntity itemEntity;
  final int quantity;
}
