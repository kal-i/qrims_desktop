import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/issuance_status.dart';
import '../../../officer/data/models/officer.dart';
import '../../../purchase_request/data/models/purchase_request.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import 'issuance.dart';
import 'issuance_item.dart';
import 'supplier.dart';

class InventoryCustodianSlipModel extends InventoryCustodianSlipEntity
    implements IssuanceModel {
  const InventoryCustodianSlipModel({
    required super.id,
    required super.icsId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    //super.batchItems,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    super.supplierEntity,
    super.deliveryReceiptId,
    super.prReferenceId,
    super.inventoryTransferReportId,
    super.inspectionAndAcceptanceReportId,
    super.contractNumber,
    super.purchaseOrderNumber,
    super.dateAcquired,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    super.receivedDate,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  factory InventoryCustodianSlipModel.fromJson(Map<String, dynamic> json) {
    print('ics model: $json');

    PurchaseRequestModel? purchaseRequest;
    EntityModel? entity;
    FundCluster? fundCluster;
    SupplierModel? supplier;

    OfficerModel? receivingOfficer;
    OfficerModel? issuingOfficer;

    if (json['purchase_request'] != null) {
      purchaseRequest = PurchaseRequestModel.fromJson(json['purchase_request']);
    }

    if (json['entity'] != null) {
      entity = EntityModel.fromJson(json['entity']);
      print('entity: $entity');
    }

    if (json['fund_cluster'] != null) {
      fundCluster = FundCluster.values.firstWhere(
        (e) => e.toString().split('.').last == json['fund_cluster'],
        orElse: () => FundCluster.unknown, // Default value
      );
    }

    if (json['supplier'] != null) {
      supplier = SupplierModel.fromJson(json['supplier']);
    }

    print('processing receiving officer ----');
    if (json['receiving_officer'] != null) {
      receivingOfficer = OfficerModel.fromJson(json['receiving_officer']);
      print('receiving officer: $receivingOfficer');
    }

    if (json['issuing_officer'] != null) {
      issuingOfficer = OfficerModel.fromJson(json['issuing_officer']);
      print('issuing officer: $issuingOfficer');
    }

    final items = (json['items'] as List<dynamic>).map((item) {
      return IssuanceItemModel.fromJson(item);
    }).toList();

    final ics = InventoryCustodianSlipModel(
      id: json['id'] as String,
      icsId: json['ics_id'] as String,
      issuedDate: json['issued_date'] is String
          ? DateTime.tryParse(json['issued_date'] as String) ?? DateTime.now()
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null
          ? json['return_date'] is String
              ? DateTime.tryParse(json['return_date'] as String)
              : json['return_date'] as DateTime
          : null,
      items: items,
      purchaseRequestEntity: purchaseRequest,
      entity: entity,
      fundCluster: fundCluster,
      supplierEntity: supplier,
      deliveryReceiptId: json['delivery_receipt_id'] as String?,
      prReferenceId: json['pr_reference_id'] as String?,
      inventoryTransferReportId:
          json['inventory_transfer_report_id'] as String?,
      inspectionAndAcceptanceReportId:
          json['inspection_and_acceptance_report_id'] as String?,
      contractNumber: json['contract_number'] as String?,
      purchaseOrderNumber: json['purchase_order_number'] as String?,
      dateAcquired:
          json['date_acquired'] != null && json['date_acquired'] is String
              ? DateTime.tryParse(json['date_acquired'] as String)
              : json['date_acquired'] as DateTime?,
      receivingOfficerEntity: receivingOfficer,
      issuingOfficerEntity: issuingOfficer,
      receivedDate: json['received_date'] != null
          ? json['received_date'] is String
              ? DateTime.parse(json['received_date'] as String)
              : json['received_date'] as DateTime
          : null,
      qrCodeImageData: json['qr_code_image_data'] as String,
      status: IssuanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => IssuanceStatus.unreceived,
      ),
      isArchived: json['is_archived'] as bool? ?? false,
    );
    print('converted ics ----');

    return ics;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ics_id': icsId,
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'items':
          items.map((item) => (item as IssuanceItemModel).toJson()).toList(),
      // 'batch_items': batchItems
      //     ?.map((batchItem) => (batchItem as BatchItemModel).toJson())
      //    .toList(),
      'purchase_request':
          (purchaseRequestEntity as PurchaseRequestModel?)?.toJson(),
      'entity': (entity as EntityModel?)?.toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'supplier': (supplierEntity as SupplierModel?)?.toJson(),
      'delivery_receipt_id': deliveryReceiptId,
      'pr_reference_id': prReferenceId,
      'inventory_transfer_report_id': inventoryTransferReportId,
      'inspection_and_acceptance_report_id': inspectionAndAcceptanceReportId,
      'contract_number': contractNumber,
      'purchase_order_number': purchaseOrderNumber,
      'date_acquired': dateAcquired?.toIso8601String(),
      'receiving_officer': (receivingOfficerEntity as OfficerModel?)?.toJson(),
      'issuing_officer': (issuingOfficerEntity as OfficerModel?)?.toJson(),
      'received_date': receivedDate?.toIso8601String(),
      'qr_code_image_data': qrCodeImageData,
      'status': status.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
