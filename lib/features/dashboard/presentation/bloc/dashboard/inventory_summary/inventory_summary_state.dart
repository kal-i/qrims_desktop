part of 'inventory_summary_bloc.dart';

sealed class InventorySummaryState extends Equatable {
  const InventorySummaryState();

  @override
  List<Object?> get props => [];
}

final class InventorySummaryInitial extends InventorySummaryState {}

final class InventorySummaryLoading extends InventorySummaryState {}

final class InventorySummaryLoaded extends InventorySummaryState {
  const InventorySummaryLoaded({
    required this.inventorySummaryEntity,
  });

  final InventorySummaryEntity inventorySummaryEntity;

  @override
  List<Object?> get props => [
        inventorySummaryEntity,
      ];
}

final class InventorySummaryError extends InventorySummaryState {
  const InventorySummaryError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
    message,
  ];
}
