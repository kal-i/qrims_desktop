import '../../../../core/enums/issuance_item_status.dart';
import '../../../item_inventory/domain/entities/base_item.dart';

class IssuanceItemEntity {
  const IssuanceItemEntity({
    required this.issuanceId,
    required this.itemEntity,
    required this.quantity,
    this.status = IssuanceItemStatus.issued,
    required this.issuedDate,
    this.receivedDate,
    this.returnedDate,
    this.lostDate,
    this.remarks,
  });

  final String issuanceId;
  final BaseItemEntity itemEntity;
  final int quantity;
  final IssuanceItemStatus status;
  final DateTime issuedDate;
  final DateTime? receivedDate;
  final DateTime? returnedDate;
  final DateTime? lostDate;
  final String? remarks;
}
