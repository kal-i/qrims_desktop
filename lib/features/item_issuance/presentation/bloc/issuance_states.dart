part of 'issuances_bloc.dart';

sealed class IssuancesState extends Equatable {
  const IssuancesState();

  @override
  List<Object?> get props => [];
}

final class IssuancesInitial extends IssuancesState {}

final class IssuancesLoading extends IssuancesState {}

final class IssuanceLoaded extends IssuancesState {
  const IssuanceLoaded({
    required this.issuance,
  });

  final IssuanceEntity issuance;

  @override
  List<Object?> get props => [
    issuance,
  ];
}

final class IssuancesLoaded extends IssuancesState {
  const IssuancesLoaded({
    required this.issuances,
    required this.totalIssuancesCount,
  });

  final List<IssuanceEntity> issuances;
  final int totalIssuancesCount;

  @override
  List<Object?> get props => [
        issuances,
        totalIssuancesCount,
      ];
}

final class IssuancesError extends IssuancesState {
  const IssuancesError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
        message,
      ];
}

final class MatchedItemWithPr extends IssuancesState {
  const MatchedItemWithPr({
    required this.matchedItemWithPrEntity,
  });

  final MatchedItemWithPrEntity matchedItemWithPrEntity;
}

final class ICSRegistered extends IssuancesState {
  const ICSRegistered({
    required this.ics,
  });

  final InventoryCustodianSlipEntity ics;
}

final class PARRegistered extends IssuancesState {
  const PARRegistered({
    required this.par,
  });

  final PropertyAcknowledgementReceiptEntity par;
}