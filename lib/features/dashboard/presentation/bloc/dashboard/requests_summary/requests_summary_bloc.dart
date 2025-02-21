import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/enums/period.dart';
import '../../../../../../core/usecases/no_params.dart';
import '../../../../domain/entities/requests_summary.dart';
import '../../../../domain/usecases/get_requests_summary.dart';

part 'requests_summary_event.dart';
part 'requests_summary_state.dart';

class RequestsSummaryBloc
    extends Bloc<RequestsSummaryEvent, RequestsSummaryState> {
  RequestsSummaryBloc({
    required GetRequestsSummary getRequestsSummary,
  })  : _getRequestsSummary = getRequestsSummary,
        super(RequestsSummaryInitial()) {
    on<GetRequestsSummaryEvent>(_onGetRequestsSummary);
  }

  final GetRequestsSummary _getRequestsSummary;

  void _onGetRequestsSummary(
    GetRequestsSummaryEvent event,
    Emitter<RequestsSummaryState> emit,
  ) async {
    emit(RequestsSummaryLoading());

    final response = await _getRequestsSummary(
      NoParams(),
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
