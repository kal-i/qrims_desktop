import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/officer_status.dart';
import '../../domain/entities/officer.dart';
import '../../domain/usecases/get_paginated_officers.dart';
import '../../domain/usecases/register_officer.dart';
import '../../domain/usecases/update_officer.dart';
import '../../domain/usecases/update_officer_archive_status.dart';

part 'officers_event.dart';
part 'officers_state.dart';

class OfficersBloc extends Bloc<OfficersEvent, OfficersState> {
  OfficersBloc({
    required GetPaginatedOfficers getPaginatedOfficers,
    required RegisterOfficer registerOfficer,
    required UpdateOfficer updateOfficer,
    required UpdateOfficerArchiveStatus updateOfficerArchiveStatus,
  })  : _getPaginatedOfficers = getPaginatedOfficers,
        _registerOfficer = registerOfficer,
        _updateOfficer = updateOfficer,
        _updateOfficerArchiveStatus = updateOfficerArchiveStatus,
        super(OfficersInitial()) {
    on<GetPaginatedOfficersEvent>(_onGetPaginatedOfficers);
    on<RegisterOfficerEvent>(_onRegisterOfficer);
    on<UpdateOfficerEvent>(_onUpdateOfficer);
    on<UpdateOfficerArchiveStatusEvent>(_onUpdateOfficerArchiveStatus);
  }

  final GetPaginatedOfficers _getPaginatedOfficers;
  final RegisterOfficer _registerOfficer;
  final UpdateOfficer _updateOfficer;
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
        office: event.office,
        sortBy: event.sortBy,
        status: event.status,
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

  void _onUpdateOfficer(
    UpdateOfficerEvent event,
    Emitter<OfficersState> emit,
  ) async {
    emit(OfficersLoading());

    final response = await _updateOfficer(
      UpdateOfficerParams(
        id: event.id,
        office: event.office,
        position: event.position,
        name: event.name,
        status: event.status,
      ),
    );

    response.fold(
      (l) => emit(
        OfficersError(message: l.message),
      ),
      (r) => emit(
        UpdatedOfficer(isSuccessful: r),
      ),
    );
  }
}
