part of 'purchase_requests_bloc.dart';

sealed class PurchaseRequestsEvent extends Equatable {
  const PurchaseRequestsEvent();

  @override
  List<Object?> get props => [];
}

final class GetPurchaseRequestsEvent extends PurchaseRequestsEvent {
  const GetPurchaseRequestsEvent({
    required this.page,
    required this.pageSize,
    this.prId,
    this.unitCost,
    this.date,
    this.prStatus,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? prId;
  final double? unitCost;
  final DateTime? date;
  final PurchaseRequestStatus? prStatus;
  final bool? isArchived;

  @override
  List<Object?> get props => [
        page,
        pageSize,
        prId,
        unitCost,
        date,
        prStatus,
        isArchived,
      ];
}

final class RegisterPurchaseRequestEvent extends PurchaseRequestsEvent {
  const RegisterPurchaseRequestEvent({
    required this.entityName,
    required this.fundCluster,
    required this.officeName,
    required this.responsibilityCenterCode,
    required this.date,
    required this.productName,
    required this.productDescription,
    required this.unit,
    required this.quantity,
    required this.unitCost,
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
  final String? responsibilityCenterCode;
  final DateTime date;
  final String productName;
  final String productDescription;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final String purpose;
  final String requestingOfficerOffice;
  final String requestingOfficerPosition;
  final String requestingOfficerName;
  final String approvingOfficerOffice;
  final String approvingOfficerPosition;
  final String approvingOfficerName;

  @override
  List<Object?> get props => [
        entityName,
        fundCluster,
        officeName,
        responsibilityCenterCode,
        date,
        productName,
        productDescription,
        unit,
        quantity,
        unitCost,
        purpose,
        requestingOfficerOffice,
        requestingOfficerPosition,
        requestingOfficerName,
        approvingOfficerOffice,
        approvingOfficerPosition,
        approvingOfficerName,
      ];
}
