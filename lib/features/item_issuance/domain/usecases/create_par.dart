import 'package:fpdart/fpdart.dart';

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
      prId: params.prId,
      issuanceItems: params.issuanceItems,
      receivingOfficerOffice: params.receivingOfficerOffice,
      receivingOfficerPosition: params.receivingOfficerPosition,
      receivingOfficerName: params.receivingOfficerName,
      sendingOfficerOffice: params.sendingOfficerOffice,
      sendingOfficerPosition: params.sendingOfficerPosition,
      sendingOfficerName: params.sendingOfficerName,
    );
  }
}

class CreatePARParams {
  const CreatePARParams({
    required this.prId,
    required this.issuanceItems,
    required this.receivingOfficerOffice,
    required this.receivingOfficerPosition,
    required this.receivingOfficerName,
    required this.sendingOfficerOffice,
    required this.sendingOfficerPosition,
    required this.sendingOfficerName,
  });

  final String prId;
  final List issuanceItems;
  final String receivingOfficerOffice;
  final String receivingOfficerPosition;
  final String receivingOfficerName;
  final String sendingOfficerOffice;
  final String sendingOfficerPosition;
  final String sendingOfficerName;
}
