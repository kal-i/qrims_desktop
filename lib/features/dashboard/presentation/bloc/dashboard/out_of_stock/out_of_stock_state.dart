part of 'out_of_stock_bloc.dart';

sealed class OutOfStockState extends Equatable {
  const OutOfStockState();

  @override
  List<Object?> get props => [];
}

final class OutOfStocksInitial extends OutOfStockState {}

final class OutOfStocksLoading extends OutOfStockState {}

final class OutOfStocksLoaded extends OutOfStockState {
  const OutOfStocksLoaded({
    required this.items,
    required this.totalItemsCount,
  });

  final List<ReusableItemInformationEntity> items;
  final int totalItemsCount;

  @override
  List<Object?> get props => [
        items,
        totalItemsCount,
      ];
}

final class OutOfStocksError extends OutOfStockState {
  const OutOfStocksError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
        message,
      ];
}
