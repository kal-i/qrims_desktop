import '../../../officer/domain/entities/office.dart';
import '../../../officer/domain/entities/officer.dart';
import 'issuance.dart';

class RequisitionAndIssueSlipEntity extends IssuanceEntity {
  const RequisitionAndIssueSlipEntity({
    required super.id,
    required this.risId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    super.purchaseRequestEntity, // get the requesting officer here
    super.entity,
    super.fundCluster,
    this.division,
    this.responsibilityCenterCode,
    this.office,
    this.purpose,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    this.approvingOfficerEntity,
    this.requestingOfficerEntity,
    super.receivedDate,
    this.approvedDate,
    this.requestDate,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  final String risId;
  final String? division;
  final String? responsibilityCenterCode;
  final OfficeEntity? office;
  final String? purpose;
  final OfficerEntity? approvingOfficerEntity;
  final OfficerEntity? requestingOfficerEntity;
  final DateTime? approvedDate;
  final DateTime? requestDate;
}
