import 'issuance.dart';
import 'supplier.dart';

class InventoryCustodianSlipEntity extends IssuanceEntity {
  const InventoryCustodianSlipEntity({
    required super.id,
    required this.icsId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    //super.batchItems,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    this.supplierEntity,
    this.deliveryReceiptId,
    this.prReferenceId,
    this.inventoryTransferReportId,
    this.inspectionAndAcceptanceReportId,
    this.contractNumber,
    this.purchaseOrderNumber,
    this.dateAcquired,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    super.receivedDate,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  final String icsId;
  final SupplierEntity? supplierEntity;
  final String? deliveryReceiptId;
  final String? prReferenceId;
  final String? inventoryTransferReportId;
  final String? inspectionAndAcceptanceReportId;
  final String? contractNumber;
  final String? purchaseOrderNumber;
  final DateTime? dateAcquired;
}
