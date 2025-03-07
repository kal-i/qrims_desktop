import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/issuance_status.dart';
import '../../../officer/data/models/office.dart';
import '../../../officer/data/models/officer.dart';
import '../../../purchase_request/data/models/purchase_request.dart';
import '../../domain/entities/requisition_and_issue_slip.dart';
import 'issuance.dart';
import 'issuance_item.dart';

class RequisitionAndIssuanceSlipModel extends RequisitionAndIssueSlipEntity
    implements IssuanceModel {
  const RequisitionAndIssuanceSlipModel({
    required super.id,
    required super.risId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    super.division,
    super.responsibilityCenterCode,
    super.office,
    super.purpose,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    super.approvingOfficerEntity,
    super.requestingOfficerEntity,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  factory RequisitionAndIssuanceSlipModel.fromJson(Map<String, dynamic> json) {
    print('ris model: $json');

    PurchaseRequestModel? purchaseRequest;
    EntityModel? entity;
    FundCluster? fundCluster;
    OfficeModel? office;
    OfficerModel? receivingOfficer;
    OfficerModel? issuingOfficer;
    OfficerModel? approvingOfficer;
    OfficerModel? requestingOfficer;

    if (json['purchase_request'] != null) {
      purchaseRequest = PurchaseRequestModel.fromJson(json['purchase_request']);
    }

    if (json['entity'] != null) {
      entity = EntityModel.fromJson(json['entity']);
    }

    if (json['fund_cluster'] != null) {
      try {
        fundCluster = FundCluster.values.firstWhere(
          (e) => e.toString().split('.').last == json['fund_cluster'],
        );
      } catch (e) {
        print('Invalid fund_cluster value: ${json['fund_cluster']}');
        fundCluster = null;
      }
    }

    if (json['office'] != null) {
      office = OfficeModel.fromJson(json['office']);
    }

    if (json['receiving_officer'] != null) {
      receivingOfficer = OfficerModel.fromJson(json['receiving_officer']);
    }

    if (json['issuing_officer'] != null) {
      issuingOfficer = OfficerModel.fromJson(json['issuing_officer']);
    }

    if (json['approving_officer'] != null) {
      approvingOfficer = OfficerModel.fromJson(json['approving_officer']);
    }

    if (json['requesting_officer'] != null) {
      requestingOfficer = OfficerModel.fromJson(json['requesting_officer']);
    }

    final items = (json['items'] as List<dynamic>).map((item) {
      final issuanceItem = IssuanceItemModel.fromJson(item);
      return issuanceItem;
    }).toList();

    final ris = RequisitionAndIssuanceSlipModel(
      id: json['id'] as String,
      risId: json['ris_id'] as String,
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
      division: json['division'] as String?,
      responsibilityCenterCode: json['responsibility_center_code'] as String?,
      office: office,
      purpose: json['purpose'] as String?,
      receivingOfficerEntity: receivingOfficer,
      issuingOfficerEntity: issuingOfficer,
      approvingOfficerEntity: approvingOfficer,
      requestingOfficerEntity: requestingOfficer,
      qrCodeImageData: json['qr_code_image_data'] as String,
      status: IssuanceStatus.values
          .firstWhere((e) => e.toString().split('.').last == json['status']),
      isArchived: json['is_archived'] as bool,
    );

    return ris;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ris_id': risId,
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'items':
          items.map((item) => (item as IssuanceItemModel).toJson()).toList(),
      'purchase_request':
          (purchaseRequestEntity as PurchaseRequestModel).toJson(),
      'entity': (entity as EntityModel).toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'division': division,
      'responsibility_center_code': responsibilityCenterCode,
      'office': (office as OfficeModel).toJson(),
      'purpose': purpose,
      'receiving_officer': (receivingOfficerEntity as OfficerModel).toJson(),
      'issuing_officer': (issuingOfficerEntity as OfficerModel).toJson(),
      'approving_officer': (approvingOfficerEntity as OfficerModel).toJson(),
      'requesting_officer': (requestingOfficerEntity as OfficerModel).toJson(),
      'qr_code_image_data': qrCodeImageData,
      'status': status.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
