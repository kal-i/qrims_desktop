part of 'stock_bloc.dart';

sealed class StocksState extends Equatable {
  const StocksState();

  @override
  List<Object?> get props => [];
}

final class StocksInitial extends StocksState {}

final class StocksLoading extends StocksState {}

final class StocksLoaded extends StocksState {
  const StocksLoaded({
    required this.stocks,
  });

  final List<StockEntity> stocks;

  @override
  List<Object?> get props => [
        stocks,
      ];
}

final class StocksError extends StocksState {
  const StocksError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
        message,
      ];
}

final class StocksProductNameFetched extends StocksState {
  const StocksProductNameFetched({
    required this.productNames,
  });

  final List<String> productNames;

  @override
  List<Object?> get props => [
        productNames,
      ];
}

final class StocksPaginatedProductNameFetched extends StocksState {
  const StocksPaginatedProductNameFetched({
    required this.productNames,
    required this.totalItemCount,
  });

  final List<String> productNames;
  final int totalItemCount;
}

final class StocksProductDescriptionFetched extends StocksState {
  const StocksProductDescriptionFetched({
    required this.productDescriptions,
  });

  final List<String> productDescriptions;

  @override
  List<Object?> get props => [
        productDescriptions,
      ];
}
