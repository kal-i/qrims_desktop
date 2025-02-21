import 'package:fpdart/src/either.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/requisition_and_issue_slip.dart';
import '../repository/issuance_repository.dart';

class CreateRIS
    implements UseCase<RequisitionAndIssueSlipEntity, CreateRISParams> {
  const CreateRIS({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, RequisitionAndIssueSlipEntity>> call(
    CreateRISParams params,
  ) async {
    return await issuanceRepository.createRIS(
      prId: params.prId,
      issuanceItems: params.issuanceItems,
      purpose: params.purpose,
      responsibilityCenterCode: params.responsibilityCenterCode,
      receivingOfficerOffice: params.receivingOfficerOffice,
      receivingOfficerPosition: params.receivingOfficerPosition,
      receivingOfficerName: params.receivingOfficerName,
      approvingOfficerOffice: params.approvingOfficerOffice,
      approvingOfficerPosition: params.approvingOfficerPosition,
      approvingOfficerName: params.approvingOfficerName,
      issuingOfficerOffice: params.issuingOfficerOffice,
      issuingOfficerPosition: params.approvingOfficerPosition,
      issuingOfficerName: params.issuingOfficerName,
    );
  }
}

class CreateRISParams {
  const CreateRISParams({
    required this.prId,
    required this.issuanceItems,
    this.purpose,
    this.responsibilityCenterCode,
    required this.receivingOfficerOffice,
    required this.receivingOfficerPosition,
    required this.receivingOfficerName,
    required this.approvingOfficerOffice,
    required this.approvingOfficerPosition,
    required this.approvingOfficerName,
    required this.issuingOfficerOffice,
    required this.issuingOfficerPosition,
    required this.issuingOfficerName,
  });

  final String prId;
  final List issuanceItems;
  final String? purpose;
  final String? responsibilityCenterCode;
  final String receivingOfficerOffice;
  final String receivingOfficerPosition;
  final String receivingOfficerName;
  final String approvingOfficerOffice;
  final String approvingOfficerPosition;
  final String approvingOfficerName;
  final String issuingOfficerOffice;
  final String issuingOfficerPosition;
  final String issuingOfficerName;
}
