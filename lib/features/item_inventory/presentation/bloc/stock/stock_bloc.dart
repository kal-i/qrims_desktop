import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/no_params.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/usecases/get_paginated_stocks_product_name.dart';
import '../../../domain/usecases/get_stocks.dart';
import '../../../domain/usecases/get_stocks_product_description.dart';
import '../../../domain/usecases/get_stocks_product_name.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StocksBloc extends Bloc<StocksEvent, StocksState> {
  StocksBloc({
    required GetStocks getStocks,
    required GetStocksProductName getStocksProductName,
    required GetPaginatedStocksProductName getPaginatedStocksProductName,
    required GetStocksProductDescription getStockProductDescription,
  })  : _getStocks = getStocks,
        _getStocksProductName = getStocksProductName,
        _getPaginatedStocksProductName = getPaginatedStocksProductName,
        _getStocksProductDescription = getStockProductDescription,
        super(StocksInitial()) {
    on<FetchStocks>(_onFetchStocks);
    on<FetchStocksProductName>(_onFetchStocksProductName);
    on<FetchPaginatedStocksProductName>(_onFetchPaginatedProductName);
    on<FetchStocksProductDescription>(_onFetchStocksProductDescription);
  }

  final GetStocks _getStocks;
  final GetStocksProductName _getStocksProductName;
  final GetPaginatedStocksProductName _getPaginatedStocksProductName;
  final GetStocksProductDescription _getStocksProductDescription;

  void _onFetchStocks(FetchStocks event, Emitter<StocksState> emit) async {
    emit(StocksLoading());

    final response = await _getStocks(NoParams());

    response.fold(
      (l) => emit(
        StocksError(message: l.message),
      ),
      (r) => emit(
        StocksLoaded(stocks: r!),
      ),
    );
  }

  void _onFetchStocksProductName(
    FetchStocksProductName event,
    Emitter<StocksState> emit,
  ) async {
    emit(StocksLoading());

    final response = await _getStocksProductName(
      event.productName,
    );

    response.fold(
      (l) => emit(
        StocksError(message: l.message),
      ),
      (r) => emit(
        StocksProductNameFetched(productNames: r!),
      ),
    );
  }

  void _onFetchPaginatedProductName(
    FetchPaginatedStocksProductName event,
    Emitter<StocksState> emit,
  ) async {
    emit(StocksLoading());

    print('bloc: ${event.productName}');
    final response = await _getPaginatedStocksProductName(
      GetPaginatedStocksProductNameParams(
        page: event.page,
        pageSize: event.pageSize,
        productName: event.productName,
      ),
    );

    response.fold(
      (l) => emit(StocksError(message: l.message)),
      (r) => emit(
        StocksPaginatedProductNameFetched(
          productNames: r.itemNames,
          totalItemCount: r.totalItemCount,
        ),
      ),
    );
  }

  void _onFetchStocksProductDescription(
    FetchStocksProductDescription event,
    Emitter<StocksState> emit,
  ) async {
    emit(StocksLoading());

    final response = await _getStocksProductDescription(
      event.productName,
    );

    response.fold(
      (l) => emit(
        StocksError(message: l.message),
      ),
      (r) => emit(
        StocksProductDescriptionFetched(productDescriptions: r!),
      ),
    );
  }
}
