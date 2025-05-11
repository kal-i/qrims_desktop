import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/error/failure.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/property_acknowledgement_receipt.dart';
import '../repository/issuance_repository.dart';

class CreatePAR
    implements UseCase<PropertyAcknowledgementReceiptEntity, CreatePARParams> {
  const CreatePAR({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, PropertyAcknowledgementReceiptEntity>> call(
    CreatePARParams params,
  ) async {
    return await issuanceRepository.createPAR(
      issuedDate: params.issuedDate,
      issuanceItems: params.issuanceItems,
      prId: params.prId,
      entityName: params.entityName,
      fundCluster: params.fundCluster,
      supplierName: params.supplierName,
      deliveryReceiptId: params.deliveryReceiptId,
      prReferenceId: params.prReferenceId,
      inventoryTransferReportId: params.inventoryTransferReportId,
      inspectionAndAcceptanceReportId: params.inspectionAndAcceptanceReportId,
      contractNumber: params.contractNumber,
      purchaseOrderNumber: params.purchaseOrderNumber,
      dateAcquired: params.dateAcquired,
      receivingOfficerOffice: params.receivingOfficerOffice,
      receivingOfficerPosition: params.receivingOfficerPosition,
      receivingOfficerName: params.receivingOfficerName,
      issuingOfficerOffice: params.issuingOfficerOffice,
      issuingOfficerPosition: params.issuingOfficerPosition,
      issuingOfficerName: params.issuingOfficerName,
      receivedDate: params.receivedDate,
    );
  }
}

class CreatePARParams {
  const CreatePARParams({
    this.issuedDate,
    required this.issuanceItems,
    this.prId,
    this.entityName,
    this.fundCluster,
    this.supplierName,
    this.deliveryReceiptId,
    this.prReferenceId,
    this.inventoryTransferReportId,
    this.inspectionAndAcceptanceReportId,
    this.contractNumber,
    this.purchaseOrderNumber,
    this.dateAcquired,
    this.receivingOfficerOffice,
    this.receivingOfficerPosition,
    this.receivingOfficerName,
    this.issuingOfficerOffice,
    this.issuingOfficerPosition,
    this.issuingOfficerName,
    this.receivedDate,
  });

  final DateTime? issuedDate;
  final List issuanceItems;
  final String? prId;
  final String? entityName;
  final FundCluster? fundCluster;
  final String? supplierName;
  final String? deliveryReceiptId;
  final String? prReferenceId;
  final String? inventoryTransferReportId;
  final String? inspectionAndAcceptanceReportId;
  final String? contractNumber;
  final String? purchaseOrderNumber;
  final DateTime? dateAcquired;
  final String? receivingOfficerOffice;
  final String? receivingOfficerPosition;
  final String? receivingOfficerName;
  final String? issuingOfficerOffice;
  final String? issuingOfficerPosition;
  final String? issuingOfficerName;
  final DateTime? receivedDate;
}
