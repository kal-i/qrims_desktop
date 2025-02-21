import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/reusable_item_information.dart';
import '../../../../domain/usecases/get_low_stock_items.dart';

part 'low_stock_event.dart';
part 'low_stock_state.dart';

class LowStockBloc extends Bloc<LowStockEvent, LowStockState> {
  LowStockBloc({
    required GetLowStockItems getLowStockItems,
  })  : _getLowStockItems = getLowStockItems,
        super(LowStockInitial()) {
    on<GetLowStockEvent>(_onGetLowStockItems);
  }

  final GetLowStockItems _getLowStockItems;

  void _onGetLowStockItems(
    GetLowStockEvent event,
    Emitter<LowStockState> emit,
  ) async {
    emit(LowStockLoading());

    final response = await _getLowStockItems(
      GetLowStockItemsParams(
        page: event.page,
        pageSize: event.pageSize,
      ),
    );

    response.fold(
      (l) => emit(LowStockError(message: l.message)),
      (r) => emit(
        LowStockLoaded(
          items: r.reusableItemInformationEntities,
        ),
      ),
    );
  }
}
