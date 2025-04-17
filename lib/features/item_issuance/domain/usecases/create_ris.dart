import 'package:fpdart/src/either.dart';

import '../../../../core/enums/fund_cluster.dart';
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
      issuedDate: params.issuedDate,
      issuanceItems: params.issuanceItems,
      prId: params.prId,
      entityName: params.entityName,
      fundCluster: params.fundCluster,
      division: params.division,
      responsibilityCenterCode: params.responsibilityCenterCode,
      officeName: params.officeName,
      purpose: params.purpose,
      receivingOfficerOffice: params.receivingOfficerOffice,
      receivingOfficerPosition: params.receivingOfficerPosition,
      receivingOfficerName: params.receivingOfficerName,
      issuingOfficerOffice: params.issuingOfficerOffice,
      issuingOfficerPosition: params.issuingOfficerPosition,
      issuingOfficerName: params.issuingOfficerName,
      approvingOfficerOffice: params.approvingOfficerOffice,
      approvingOfficerPosition: params.approvingOfficerPosition,
      approvingOfficerName: params.approvingOfficerName,
      requestingOfficerOffice: params.requestingOfficerOffice,
      requestingOfficerPosition: params.requestingOfficerPosition,
      requestingOfficerName: params.requestingOfficerName,
      receivedDate: params.receivedDate,
      approvedDate: params.approvedDate,
      requestDate: params.requestDate,
    );
  }
}

class CreateRISParams {
  const CreateRISParams({
    this.issuedDate,
    required this.issuanceItems,
    this.prId,
    this.entityName,
    this.fundCluster,
    this.division,
    this.responsibilityCenterCode,
    this.officeName,
    this.purpose,
    this.receivingOfficerOffice,
    this.receivingOfficerPosition,
    this.receivingOfficerName,
    this.issuingOfficerOffice,
    this.issuingOfficerPosition,
    this.issuingOfficerName,
    this.approvingOfficerOffice,
    this.approvingOfficerPosition,
    this.approvingOfficerName,
    this.requestingOfficerOffice,
    this.requestingOfficerPosition,
    this.requestingOfficerName,
    this.receivedDate,
    this.approvedDate,
    this.requestDate,
  });

  final DateTime? issuedDate;
  final List issuanceItems;
  final String? prId;
  final String? entityName;
  final FundCluster? fundCluster;
  final String? division;
  final String? responsibilityCenterCode;
  final String? officeName;
  final String? purpose;
  final String? receivingOfficerOffice;
  final String? receivingOfficerPosition;
  final String? receivingOfficerName;
  final String? issuingOfficerOffice;
  final String? issuingOfficerPosition;
  final String? issuingOfficerName;
  final String? approvingOfficerOffice;
  final String? approvingOfficerPosition;
  final String? approvingOfficerName;
  final String? requestingOfficerOffice;
  final String? requestingOfficerPosition;
  final String? requestingOfficerName;
  final DateTime? receivedDate;
  final DateTime? approvedDate;
  final DateTime? requestDate;
}
