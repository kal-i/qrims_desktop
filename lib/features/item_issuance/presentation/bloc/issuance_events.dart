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

final class CreatePAREvent extends IssuancesEvent {
  const CreatePAREvent({
    required this.prId,
    this.propertyNumber,
    required this.issuanceItems,
    required this.receivingOfficerOffice,
    required this.receivingOfficerPosition,
    required this.receivingOfficerName,
    required this.sendingOfficerOffice,
    required this.sendingOfficerPosition,
    required this.sendingOfficerName,
  });

  final String prId;
  final String? propertyNumber;
  final List issuanceItems;
  final String receivingOfficerOffice;
  final String receivingOfficerPosition;
  final String receivingOfficerName;
  final String sendingOfficerOffice;
  final String sendingOfficerPosition;
  final String sendingOfficerName;
}
