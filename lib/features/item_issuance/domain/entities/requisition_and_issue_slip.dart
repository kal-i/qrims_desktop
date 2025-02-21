import '../../../officer/domain/entities/officer.dart';
import 'issuance.dart';

class RequisitionAndIssueSlipEntity extends IssuanceEntity {
  const RequisitionAndIssueSlipEntity({
    required super.id,
    required this.risId,
    this.purpose,
    this.responsibilityCenterCode,
    required super.items,
    required super.purchaseRequestEntity,
    required super.receivingOfficerEntity,
    required this.approvingOfficerEntity,
    required this.issuingOfficerEntity,
    required super.issuedDate,
    super.returnDate,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  final String risId;
  final String? purpose;
  final String? responsibilityCenterCode;
  final OfficerEntity approvingOfficerEntity;
  final OfficerEntity issuingOfficerEntity;
}
