import 'package:fpdart/src/either.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/ics_type.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_custodian_slip.dart';
import '../repository/issuance_repository.dart';

class CreateMultipleICS
    implements
        UseCase<List<InventoryCustodianSlipEntity>, CreateMultipleICSParams> {
  const CreateMultipleICS({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, List<InventoryCustodianSlipEntity>>> call(
    CreateMultipleICSParams params,
  ) async {
    return await issuanceRepository.createMultipleICS(
      issuedDate: params.issuedDate,
      type: params.type,
      receivingOfficers: params.receivingOfficers,
      entityName: params.entityName,
      fundCluster: params.fundCluster,
      supplierName: params.supplierName,
      inspectionAndAcceptanceReportId: params.inspectionAndAcceptanceReportId,
      contractNumber: params.contractNumber,
      purchaseOrderNumber: params.purchaseOrderNumber,
      issuingOfficerOffice: params.issuingOfficerOffice,
      issuingOfficerPosition: params.issuingOfficerPosition,
      issuingOfficerName: params.issuingOfficerName,
      receivedDate: params.receivedDate,
    );
  }
}

class CreateMultipleICSParams {
  const CreateMultipleICSParams({
    this.issuedDate,
    this.type,
    required this.receivingOfficers,
    this.prId,
    this.entityName,
    this.fundCluster,
    this.supplierName,
    this.inspectionAndAcceptanceReportId,
    this.contractNumber,
    this.purchaseOrderNumber,
    this.issuingOfficerOffice,
    this.issuingOfficerPosition,
    this.issuingOfficerName,
    this.receivedDate,
  });

  final DateTime? issuedDate;
  final IcsType? type;
  final List receivingOfficers;
  final String? prId;
  final String? entityName;
  final FundCluster? fundCluster;
  final String? supplierName;
  final String? inspectionAndAcceptanceReportId;
  final String? contractNumber;
  final String? purchaseOrderNumber;
  final String? issuingOfficerOffice;
  final String? issuingOfficerPosition;
  final String? issuingOfficerName;
  final DateTime? receivedDate;
}
