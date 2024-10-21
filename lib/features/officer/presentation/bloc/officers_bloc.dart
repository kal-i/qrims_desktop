import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/officer.dart';
import '../../domain/usecases/get_paginated_officers.dart';
import '../../domain/usecases/register_officer.dart';
import '../../domain/usecases/update_officer_archive_status.dart';

part 'officers_event.dart';
part 'officers_state.dart';

class OfficersBloc extends Bloc<OfficersEvent, OfficersState> {
  OfficersBloc({
    required GetPaginatedOfficers getPaginatedOfficers,
    required RegisterOfficer registerOfficer,
    required UpdateOfficerArchiveStatus updateOfficerArchiveStatus,
  })  : _getPaginatedOfficers = getPaginatedOfficers,
        _registerOfficer = registerOfficer,
        _updateOfficerArchiveStatus = updateOfficerArchiveStatus,
        super(OfficersInitial()) {
    on<GetPaginatedOfficersEvent>(_onGetPaginatedOfficers);
    on<RegisterOfficerEvent>(_onRegisterOfficer);
    on<UpdateOfficerArchiveStatusEvent>(_onUpdateOfficerArchiveStatus);
  }

  final GetPaginatedOfficers _getPaginatedOfficers;
  final RegisterOfficer _registerOfficer;
  final UpdateOfficerArchiveStatus _updateOfficerArchiveStatus;

  void _onGetPaginatedOfficers(
    GetPaginatedOfficersEvent event,
    Emitter<OfficersState> emit,
  ) async {
    emit(OfficersLoading());

    final response = await _getPaginatedOfficers(
      GetPaginatedOfficersParams(
        page: event.page,
        pageSize: event.pageSize,
        searchQuery: event.searchQuery,
        sortBy: event.sortBy,
        sortAscending: event.sortAscending,
        isArchived: event.isArchived,
      ),
    );

    response.fold(
      (l) => emit(
        OfficersError(message: l.message),
      ),
      (r) => emit(
        OfficersLoaded(
          officers: r.officers,
          totalOfficersCount: r.totalItemsCount,
        ),
      ),
    );
  }

  void _onRegisterOfficer(
    RegisterOfficerEvent event,
    Emitter<OfficersState> emit,
  ) async {
    emit(OfficersLoading());

    final response = await _registerOfficer(
      RegisterOfficerParams(
        name: event.name,
        officeName: event.officeName,
        positionName: event.positionName,
      ),
    );

    response.fold(
      (l) => emit(
        OfficersError(message: l.message),
      ),
      (r) => emit(
        OfficerRegistered(officer: r),
      ),
    );
  }

  void _onUpdateOfficerArchiveStatus(
    UpdateOfficerArchiveStatusEvent event,
    Emitter<OfficersState> emit,
  ) async {
    emit(OfficersLoading());

    final response = await _updateOfficerArchiveStatus(
      UpdateOfficerArchiveStatusParams(
        id: event.id,
        isArchived: event.isArchived,
      ),
    );

    response.fold(
      (l) => emit(
        OfficersError(message: l.message),
      ),
      (r) => emit(
        OfficersArchiveStatusUpdated(isSuccessful: r),
      ),
    );
  }
}
