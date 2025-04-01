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
    this.requestingOfficerName,
    this.searchQuery,
    this.unitCost,
    this.startDate,
    this.endDate,
    this.prStatus,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? prId;
  final String? requestingOfficerName;
  final String? searchQuery;
  final double? unitCost;
  final DateTime? startDate;
  final DateTime? endDate;
  final PurchaseRequestStatus? prStatus;
  final bool? isArchived;

  @override
  List<Object?> get props => [
        page,
        pageSize,
        prId,
        requestingOfficerName,
        searchQuery,
        unitCost,
        startDate,
        endDate,
        prStatus,
        isArchived,
      ];
}

final class RegisterPurchaseRequestEvent extends PurchaseRequestsEvent {
  const RegisterPurchaseRequestEvent({
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

  @override
  List<Object?> get props => [
        entityName,
        fundCluster,
        officeName,
        date,
        requestedItems,
        purpose,
        requestingOfficerOffice,
        requestingOfficerPosition,
        requestingOfficerName,
        approvingOfficerOffice,
        approvingOfficerPosition,
        approvingOfficerName,
      ];
}

final class UpdatePurchaseRequestEvent extends PurchaseRequestsEvent {
  const UpdatePurchaseRequestEvent({
    required this.id,
    required this.status,
  });

  final String id;
  final PurchaseRequestStatus status;
}

final class GetPurchaseRequestByIdEvent extends PurchaseRequestsEvent {
  const GetPurchaseRequestByIdEvent({
    required this.prId,
  });

  final String prId;
}
