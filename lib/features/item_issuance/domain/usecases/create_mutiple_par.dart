import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/error/failure.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/property_acknowledgement_receipt.dart';
import '../repository/issuance_repository.dart';

class CreateMultiplePAR
    implements
        UseCase<List<PropertyAcknowledgementReceiptEntity>,
            CreateMultiplePARParams> {
  const CreateMultiplePAR({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, List<PropertyAcknowledgementReceiptEntity>>> call(
    CreateMultiplePARParams params,
  ) async {
    return await issuanceRepository.createMultiplePAR(
      issuedDate: params.issuedDate,
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

class CreateMultiplePARParams {
  const CreateMultiplePARParams({
    this.issuedDate,
    required this.receivingOfficers,
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
  final List receivingOfficers;
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
