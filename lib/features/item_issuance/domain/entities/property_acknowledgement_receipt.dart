import 'issuance.dart';
import 'supplier.dart';

class PropertyAcknowledgementReceiptEntity extends IssuanceEntity {
  const PropertyAcknowledgementReceiptEntity({
    required super.id,
    required this.parId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    this.supplierEntity,
    this.inspectionAndAcceptanceReportId,
    this.contractNumber,
    this.purchaseOrderNumber,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  final String parId;
  final SupplierEntity? supplierEntity;
  final String? inspectionAndAcceptanceReportId;
  final String? contractNumber;
  final String? purchaseOrderNumber;
}
