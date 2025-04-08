part of 'issuances_bloc.dart';

sealed class IssuancesEvent extends Equatable {
  const IssuancesEvent();

  @override
  List<Object?> get props => [];
}

final class GetPaginatedIssuancesEvent extends IssuancesEvent {
  const GetPaginatedIssuancesEvent({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.issueDateStart,
    this.issueDateEnd,
    this.type,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final DateTime? issueDateStart;
  final DateTime? issueDateEnd;
  final String? type;
  final bool? isArchived;
}

final class MatchItemWithPrEvent extends IssuancesEvent {
  const MatchItemWithPrEvent({
    required this.prId,
  });

  final String prId;
}

final class CreateICSEvent extends IssuancesEvent {
  const CreateICSEvent({
    this.issuedDate,
    this.type,
    required this.issuanceItems,
    this.prId,
    this.entityName,
    this.fundCluster,
    this.supplierName,
    this.inspectionAndAcceptanceReportId,
    this.contractNumber,
    this.purchaseOrderNumber,
    this.receivingOfficerOffice,
    this.receivingOfficerPosition,
    this.receivingOfficerName,
    this.issuingOfficerOffice,
    this.issuingOfficerPosition,
    this.issuingOfficerName,
  });

  final DateTime? issuedDate;
  final IcsType? type;
  final List issuanceItems;
  final String? prId;
  final String? entityName;
  final FundCluster? fundCluster;
  final String? supplierName;
  final String? inspectionAndAcceptanceReportId;
  final String? contractNumber;
  final String? purchaseOrderNumber;
  final String? receivingOfficerOffice;
  final String? receivingOfficerPosition;
  final String? receivingOfficerName;
  final String? issuingOfficerOffice;
  final String? issuingOfficerPosition;
  final String? issuingOfficerName;
}

final class CreatePAREvent extends IssuancesEvent {
  const CreatePAREvent({
    this.issuedDate,
    required this.issuanceItems,
    this.prId,
    this.entityName,
    this.fundCluster,
    this.supplierName,
    this.inspectionAndAcceptanceReportId,
    this.contractNumber,
    this.purchaseOrderNumber,
    this.receivingOfficerOffice,
    this.receivingOfficerPosition,
    this.receivingOfficerName,
    this.issuingOfficerOffice,
    this.issuingOfficerPosition,
    this.issuingOfficerName,
  });

  final DateTime? issuedDate;
  final List issuanceItems;
  final String? prId;
  final String? entityName;
  final FundCluster? fundCluster;
  final String? supplierName;
  final String? inspectionAndAcceptanceReportId;
  final String? contractNumber;
  final String? purchaseOrderNumber;
  final String? receivingOfficerOffice;
  final String? receivingOfficerPosition;
  final String? receivingOfficerName;
  final String? issuingOfficerOffice;
  final String? issuingOfficerPosition;
  final String? issuingOfficerName;
}

final class CreateRISEvent extends IssuancesEvent {
  const CreateRISEvent({
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
}

final class GetIssuanceByIdEvent extends IssuancesEvent {
  const GetIssuanceByIdEvent({
    required this.id,
  });

  final String id;
}

final class UpdateIssuanceArchiveStatusEvent extends IssuancesEvent {
  const UpdateIssuanceArchiveStatusEvent({
    required this.id,
    required this.isArchived,
  });

  final String id;
  final bool isArchived;
}

final class GetInventorySupplyReportEvent extends IssuancesEvent {
  const GetInventorySupplyReportEvent({
    required this.startDate,
    this.endDate,
  });

  final DateTime startDate;
  final DateTime? endDate;
}

final class GetInventorySemiExpendablePropertyReportEvent
    extends IssuancesEvent {
  const GetInventorySemiExpendablePropertyReportEvent({
    required this.startDate,
    this.endDate,
    this.assetSubClass,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final AssetSubClass? assetSubClass;
}

final class GetInventoryPropertyReportEvent extends IssuancesEvent {
  const GetInventoryPropertyReportEvent({
    required this.startDate,
    this.endDate,
    this.assetSubClass,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final AssetSubClass? assetSubClass;
}

final class GenerateSemiExpendablePropertyCardDataEvent extends IssuancesEvent {
  const GenerateSemiExpendablePropertyCardDataEvent({
    required this.icsId,
    required this.fundCluster,
  });

  final String icsId;
  final FundCluster fundCluster;
}
