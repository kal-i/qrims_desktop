import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/issuance_status.dart';
import '../../../officer/data/models/officer.dart';
import '../../../purchase_request/data/models/purchase_request.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import 'issuance.dart';
import 'issuance_item.dart';
import 'supplier.dart';

class PropertyAcknowledgementReceiptModel
    extends PropertyAcknowledgementReceiptEntity implements IssuanceModel {
  const PropertyAcknowledgementReceiptModel({
    required super.id,
    required super.parId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
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

  factory PropertyAcknowledgementReceiptModel.fromJson(
      Map<String, dynamic> json) {
    print('supplier json: ${json['supplier']}');
    print('par model: $json');

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
    }

    if (json['fund_cluster'] != null) {
      fundCluster = FundCluster.values.firstWhere(
          (e) => e.toString().split('.').last == json['fund_cluster']);
    }

    // try {
    //   print('Starting supplier conversion');
    //   if (json.containsKey('supplier')) {
    //     print('Supplier key exists in JSON');
    //     if (json['supplier'] != null) {
    //       print('Supplier JSON type: ${json['supplier'].runtimeType}');
    //       print('Supplier JSON content: ${json['supplier']}');
    //       supplier = SupplierModel.fromJson(json['supplier']);
    //       print('Converted supplier: $supplier');
    //     } else {
    //       print('Supplier value is null');
    //     }
    //   } else {
    //     print('Supplier key does not exist in JSON');
    //   }
    // } catch (e, stacktrace) {
    //   print('Error during supplier conversion: $e');
    //   print('Stacktrace: $stacktrace');
    // }

    if (json['supplier'] != null) {
      supplier = SupplierModel.fromJson(json['supplier']);
    }

    if (json['receiving_officer'] != null) {
      receivingOfficer = OfficerModel.fromJson(json['receiving_officer']);
    }

    if (json['issuing_officer'] != null) {
      issuingOfficer = OfficerModel.fromJson(json['issuing_officer']);
    }

    final items = (json['items'] as List<dynamic>).map((item) {
      final issuanceItem = IssuanceItemModel.fromJson(item);
      return issuanceItem;
    }).toList();

    print('conversion of items complete: $items');

    final par = PropertyAcknowledgementReceiptModel(
      id: json['id'] as String,
      parId: json['par_id'] as String,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null && json['return_date'] is String
          ? DateTime.parse(json['return_date'] as String)
          : json['return_date'] as DateTime?,
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
      status: IssuanceStatus.values
          .firstWhere((e) => e.toString().split('.').last == json['status']),
      isArchived: json['is_archived'] as bool,
    );
    print('converted par -----');

    return par;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'par_id': parId,
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'items':
          items.map((item) => (item as IssuanceItemModel).toJson()).toList(),
      'purchase_request':
          (purchaseRequestEntity as PurchaseRequestModel).toJson(),
      'entity': (entity as EntityModel).toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'supplier': (supplierEntity as SupplierModel).toJson(),
      'inspection_and_acceptance_report_id': inspectionAndAcceptanceReportId,
      'contract_number': contractNumber,
      'purchase_order_number': purchaseOrderNumber,
      'receiving_officer': (receivingOfficerEntity as OfficerModel).toJson(),
      'issuing_officer': (issuingOfficerEntity as OfficerModel).toJson(),
      'received_date': receivedDate?.toIso8601String(),
      'qr_code_image_data': qrCodeImageData,
      'status': status.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
