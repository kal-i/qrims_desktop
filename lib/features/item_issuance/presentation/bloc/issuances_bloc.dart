import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inventory_custodian_slip.dart';
import '../../domain/entities/issuance.dart';
import '../../domain/entities/matched_item_with_pr.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import '../../domain/usecases/create_ics.dart';
import '../../domain/usecases/create_par.dart';
import '../../domain/usecases/get_issuance_by_id.dart';
import '../../domain/usecases/get_paginated_issuances.dart';
import '../../domain/usecases/match_item_with_pr.dart';

part 'issuance_events.dart';
part 'issuance_states.dart';

class IssuancesBloc extends Bloc<IssuancesEvent, IssuancesState> {
  IssuancesBloc({
    required GetIssuanceById getIssuanceById,
    required GetPaginatedIssuances getPaginatedIssuances,
    required MatchItemWithPr matchItemWithPr,
    required CreateICS createICS,
    required CreatePAR createPAR,
  })  : _getIssuanceById = getIssuanceById,
        _getPaginatedIssuances = getPaginatedIssuances,
        _matchItemWithPr = matchItemWithPr,
        _createICS = createICS,
        _createPar = createPAR,
        super(IssuancesInitial()) {
    on<GetIssuanceByIdEvent>(_onGetIssuanceByIdEvent);
    on<GetPaginatedIssuancesEvent>(_onGetPaginatedIssuancesEvent);
    on<MatchItemWithPrEvent>(_onMatchItemWithPrEvent);
    on<CreateICSEvent>(_onCreateICS);
    on<CreatePAREvent>(_onCreatePAR);
  }

  final GetIssuanceById _getIssuanceById;
  final GetPaginatedIssuances _getPaginatedIssuances;
  final MatchItemWithPr _matchItemWithPr;
  final CreateICS _createICS;
  final CreatePAR _createPar;

  void _onGetIssuanceByIdEvent(
    GetIssuanceByIdEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getIssuanceById(event.id);

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        IssuanceLoaded(
          issuance: r!,
        ),
      ),
    );
  }

  void _onGetPaginatedIssuancesEvent(
    GetPaginatedIssuancesEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getPaginatedIssuances(
      GetPaginatedIssuancesParams(
        page: event.page,
        pageSize: event.pageSize,
        searchQuery: event.searchQuery,
        issueDateStart: event.issueDateStart,
        issueDateEnd: event.issueDateEnd,
        type: event.type,
        isArchived: event.isArchived,
      ),
    );

    print('iss bloc: $response');

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        IssuancesLoaded(
          issuances: r.issuances,
          totalIssuancesCount: r.totalIssuanceCount,
        ),
      ),
    );
  }

  void _onMatchItemWithPrEvent(
    MatchItemWithPrEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _matchItemWithPr(
      event.prId,
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        MatchedItemWithPr(
          matchedItemWithPrEntity: r,
        ),
      ),
    );
  }

  void _onCreateICS(
    CreateICSEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _createICS(
      CreateICSParams(
        prId: event.prId,
        issuanceItems: event.issuanceItems,
        receivingOfficerOffice: event.receivingOfficerOffice,
        receivingOfficerPosition: event.receivingOfficerPosition,
        receivingOfficerName: event.receivingOfficerName,
        sendingOfficerOffice: event.sendingOfficerOffice,
        sendingOfficerPosition: event.sendingOfficerPosition,
        sendingOfficerName: event.sendingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        ICSRegistered(
          ics: r,
        ),
      ),
    );
  }

  void _onCreatePAR(
    CreatePAREvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _createPar(
      CreatePARParams(
        prId: event.prId,
        propertyNumber: event.propertyNumber,
        issuanceItems: event.issuanceItems,
        receivingOfficerOffice: event.receivingOfficerOffice,
        receivingOfficerPosition: event.receivingOfficerPosition,
        receivingOfficerName: event.receivingOfficerName,
        sendingOfficerOffice: event.sendingOfficerOffice,
        sendingOfficerPosition: event.sendingOfficerPosition,
        sendingOfficerName: event.sendingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        PARRegistered(
          par: r,
        ),
      ),
    );
  }
}