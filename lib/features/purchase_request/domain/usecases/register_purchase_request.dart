import 'package:fpdart/src/either.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/purchase_request.dart';
import '../repository/purchase_request_repository.dart';

class RegisterPurchaseRequest
    implements UseCase<PurchaseRequestEntity, RegisterPurchaseRequestParams> {
  const RegisterPurchaseRequest({
    required this.purchaseRequestRepository,
  });

  final PurchaseRequestRepository purchaseRequestRepository;

  @override
  Future<Either<Failure, PurchaseRequestEntity>> call(
      RegisterPurchaseRequestParams params) async {
    return purchaseRequestRepository.registerPurchaseRequest(
      entityName: params.entityName,
      fundCluster: params.fundCluster,
      officeName: params.officeName,
      date: params.date,
      requestedItems: params.requestedItems,
      purpose: params.purpose,
      requestingOfficerOffice: params.requestingOfficerOffice,
      requestingOfficerPosition: params.requestingOfficerPosition,
      requestingOfficerName: params.requestingOfficerName,
      approvingOfficerOffice: params.approvingOfficerOffice,
      approvingOfficerPosition: params.approvingOfficerPosition,
      approvingOfficerName: params.approvingOfficerName,
    );
  }
}

class RegisterPurchaseRequestParams {
  const RegisterPurchaseRequestParams({
    required this.entityName,
    required this.fundCluster,
    required this.officeName,
    required this.date,
    required this.requestedItems,
    required this.purpose,
    required this.requestingOfficerOffice,
    required this.requestingOfficerPosition,
    required this.requestingOfficerName,
    required this.approvingOfficerOffice,
    required this.approvingOfficerPosition,
    required this.approvingOfficerName,
  });

  final String entityName;
  final FundCluster fundCluster;
  final String officeName;
  final DateTime date;
  final List<Map<String, dynamic>> requestedItems;
  final String purpose;
  final String requestingOfficerOffice;
  final String requestingOfficerPosition;
  final String requestingOfficerName;
  final String approvingOfficerOffice;
  final String approvingOfficerPosition;
  final String approvingOfficerName;
}
