import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/enums/period.dart';
import '../../../../domain/entities/requests_summary.dart';
import '../../../../domain/usecases/get_most_requested_items.dart';

part 'requests_summary_event.dart';
part 'requests_summary_state.dart';

class RequestsSummaryBloc extends Bloc<RequestsSummaryEvent, RequestsSummaryState> {
  RequestsSummaryBloc({
    required GetMostRequestedItems getMostRequestedItems,
  })  :
        _getMostRequestedItems = getMostRequestedItems,
        super(RequestsSummaryInitial()) {
    on<GetMostRequestedItemsEvent>(_onGetMostRequestedItems);
  }

  final GetMostRequestedItems _getMostRequestedItems;

  void _onGetMostRequestedItems(
    GetMostRequestedItemsEvent event,
    Emitter<RequestsSummaryState> emit,
  ) async {
    emit(RequestsSummaryInitial());

    final response = await _getMostRequestedItems(
      GetMostRequestedItemsParams(
        limit: event.limit,
        period: event.period,
      ),
    );

    response.fold(
      (l) => emit(RequestsSummaryError(message: l.message)),
      (r) => emit(
        RequestsSummaryLoaded(
          requestsSummaryEntity: r,
        ),
      ),
    );
  }
}
