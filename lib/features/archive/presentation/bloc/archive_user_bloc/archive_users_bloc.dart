import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/entities/user.dart';
import '../../../../../core/enums/auth_status.dart';
import '../../../domain/users/usecases/get_archived_users.dart';
import '../../../domain/users/usecases/update_user_archive_status.dart';

part 'archive_users_event.dart';
part 'archive_users_state.dart';


class ArchiveUsersBloc
    extends Bloc<ArchiveUsersEvent, ArchiveUsersState> {
  ArchiveUsersBloc({
    required GetArchivedUsers getArchivedUsers,
    required UpdateUserIsArchiveStatus updateUserArchiveStatus,
  })  : _getArchivedUsers = getArchivedUsers,
        _updateUserArchiveStatus = updateUserArchiveStatus,
        super(ArchivedUsersInitial()) {
    on<GetArchivedUsersEvent>(_onFetchArchivedUsers);
    on<UpdateUserArchiveStatusEvent>(_onUpdateArchiveStatus);
  }

  final GetArchivedUsers _getArchivedUsers;
  final UpdateUserIsArchiveStatus _updateUserArchiveStatus;

  void _onFetchArchivedUsers(
      GetArchivedUsersEvent event,
      Emitter<ArchiveUsersState> emit,
      ) async {
    emit(ArchivedUsersLoading());

    final response = await _getArchivedUsers(
      GetArchiveUsersParams(
        page: event.page,
        pageSize: event.pageSize,
        searchQuery: event.searchQuery,
        role: event.role,
        status: event.authStatus,
        isArchived: event.isArchived,
      ),
    );

    print(response);

    response.fold((l) {
      emit(ArchivedUsersError(message: l.message));
      print('Error loading users: ${l.message}');
    }, (r) {
      emit(
        ArchivedUsersLoaded(
          users: r.users,
          totalUserCount: r.totalUserCount,
        ),
      );
      print(
          'Loaded users for page ${event.page}: ${r.users.length}, total count: ${r.totalUserCount}');
    });
  }

  void _onUpdateArchiveStatus(
      UpdateUserArchiveStatusEvent event,
      Emitter<ArchiveUsersState> emit,
      ) async {
    emit(ArchivedUsersLoading());

    print('bloc data: ${event.isArchived}');

    final response = await _updateUserArchiveStatus(
      UpdateUserArchiveStatusParams(
        id: event.userId,
        isArchived: event.isArchived,
      ),
    );

    response.fold(
          (l) {
        print('Error updating user archive status: ${l.message}');
        emit(ArchivedUsersError(message: l.message));
      },
          (r) {
        print('User archive status updated successfully: $r');
        emit(UserArchiveStatusUpdated(isSuccessful: r));
      },
    );
  }
}

