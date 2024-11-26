part of 'inventory_summary_bloc.dart';

sealed class InventorySummaryEvent extends Equatable {
  const InventorySummaryEvent();

  @override
  List<Object?> get props => [];
}

final class GetInventorySummaryEvent extends InventorySummaryEvent {}
