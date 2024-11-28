part of 'low_stock_bloc.dart';

sealed class LowStockEvent extends Equatable {
  const LowStockEvent();

  @override
  List<Object?> get props => [];
}

final class GetLowStockEvent extends LowStockEvent {
  const GetLowStockEvent({
    required this.page,
    required this.pageSize,
  });

  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [
        page,
        pageSize,
      ];
}
