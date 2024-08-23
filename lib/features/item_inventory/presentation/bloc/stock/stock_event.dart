part of 'stock_bloc.dart';

sealed class StocksEvent extends Equatable {
  const StocksEvent();

  @override
  List<Object?> get props => [];
}

final class FetchStocks extends StocksEvent {}

final class FetchStocksProductName extends StocksEvent {
  const FetchStocksProductName({
    this.productName,
  });

  final String? productName;
}

final class FetchPaginatedStocksProductName extends StocksEvent {
  const FetchPaginatedStocksProductName({
    this.page,
    this.pageSize,
    this.productName,
  });

  final int? page;
  final int? pageSize;
  final String? productName;
}

final class FetchStocksProductDescription extends StocksEvent {
  const FetchStocksProductDescription({
    required this.productName,
  });

  final String productName;
}
