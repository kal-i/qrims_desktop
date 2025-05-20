import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/reusable_item_information.dart';
import '../../../../domain/usecases/get_out_of_stock_items.dart';

part 'out_of_stock_event.dart';
part 'out_of_stock_state.dart';

class OutOfStockBloc extends Bloc<OutOfStockEvent, OutOfStockState> {
  OutOfStockBloc({
    required GetOutOfStockItems getOutOfStockItems,
  })  : _getOutOfStockItems = getOutOfStockItems,
        super(OutOfStocksInitial()) {
    on<GetOutOfStockEvent>(_onGetLowStockItems);
  }

  final GetOutOfStockItems _getOutOfStockItems;

  void _onGetLowStockItems(
    GetOutOfStockEvent event,
    Emitter<OutOfStockState> emit,
  ) async {
    emit(OutOfStocksLoading());

    final response = await _getOutOfStockItems(
      GetOutOfStockItemsParams(
        page: event.page,
        pageSize: event.pageSize,
      ),
    );

    response.fold(
      (l) => emit(
        OutOfStocksError(message: l.message),
      ),
      (r) => emit(
        OutOfStocksLoaded(
          items: r.reusableItemInformationEntities,
          totalItemsCount: r.totalItemCount,
        ),
      ),
    );
  }
}
