import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_custodian_slip.dart';
import '../repository/issuance_repository.dart';

class CreateICS
    implements UseCase<InventoryCustodianSlipEntity, CreateICSParams> {
  const CreateICS({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, InventoryCustodianSlipEntity>> call(
      CreateICSParams params) async {
    return await issuanceRepository.createICS(
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

class CreateICSParams {
  const CreateICSParams({
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
