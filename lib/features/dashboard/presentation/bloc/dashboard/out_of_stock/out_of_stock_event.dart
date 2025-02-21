part of 'out_of_stock_bloc.dart';

sealed class OutOfStockEvent extends Equatable {
  const OutOfStockEvent();

  @override
  List<Object?> get props => [];
}

final class GetOutOfStockEvent extends OutOfStockEvent {
  const GetOutOfStockEvent({
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
