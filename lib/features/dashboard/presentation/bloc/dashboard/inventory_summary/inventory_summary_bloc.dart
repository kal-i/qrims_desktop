import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/usecases/no_params.dart';
import '../../../../domain/entities/inventory_summary.dart';
import '../../../../domain/usecases/get_inventory_summary.dart';

part 'inventory_summary_event.dart';
part 'inventory_summary_state.dart';

class InventorySummaryBloc
    extends Bloc<InventorySummaryEvent, InventorySummaryState> {
  InventorySummaryBloc({
    required GetInventorySummary getInventorySummary,
  })  : _getInventorySummary = getInventorySummary,
        super(InventorySummaryInitial()) {
    on<GetInventorySummaryEvent>(_onGetInventorySummary);
  }

  final GetInventorySummary _getInventorySummary;

  void _onGetInventorySummary(
    GetInventorySummaryEvent event,
    Emitter<InventorySummaryState> emit,
  ) async {
    emit(InventorySummaryLoading());

    final response = await _getInventorySummary(
      NoParams(),
    );

    response.fold(
      (l) => emit(InventorySummaryError(message: l.message)),
      (r) => emit(
        InventorySummaryLoaded(
          inventorySummaryEntity: r,
        ),
      ),
    );
  }
}
