import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/entities/mobile_user.dart';
import '../../../../core/entities/user.dart';
import '../../../../core/enums/admin_approval_status.dart';
import '../../../../core/enums/auth_status.dart';
import '../../domain/usecases/get_pending_users.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/update_admin_approval_status.dart';
import '../../domain/usecases/update_user_archive_status.dart';
import '../../domain/usecases/update_user_auth_status.dart';

part 'users_management_event.dart';
part 'users_management_state.dart';

class UsersManagementBloc
    extends Bloc<UsersManagementEvent, UsersManagementState> {
  UsersManagementBloc({
    required GetUsers getUsers,
    required GetPendingUsers getPendingUsers,
    required UpdateUserAuthStatus updateUserAuthStatus,
    required UpdateUserArchiveStatus updateUserArchiveStatus,
    required UpdateAdminApprovalStatus updateAdminApprovalStatus,
  })  : _getUsers = getUsers,
        _getPendingUsers = getPendingUsers,
        _updateUserAuthStatus = updateUserAuthStatus,
        _updateUserArchiveStatus = updateUserArchiveStatus,
        _updateAdminApprovalStatus = updateAdminApprovalStatus,
        super(UsersInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<FetchPendingUsersEvent>(_onFetchPendingUsers);
    on<UpdateUserAuthenticationStatusEvent>(_onUpdateUserAuth);
    on<UpdateArchiveStatusEvent>(_onUpdateArchiveStatus);
    on<UpdateAdminApprovalStatusEvent>(_onUpdateAdminApprovalStatus);
  }

  final GetUsers _getUsers;
  final GetPendingUsers _getPendingUsers;
  final UpdateUserAuthStatus _updateUserAuthStatus;
  final UpdateUserArchiveStatus _updateUserArchiveStatus;
  final UpdateAdminApprovalStatus _updateAdminApprovalStatus;

  void _onFetchUsers(
    FetchUsersEvent event,
    Emitter<UsersManagementState> emit,
  ) async {
    emit(UsersLoading());

    final response = await _getUsers(
      GetUsersParams(
        page: event.page,
        pageSize: event.pageSize,
        searchQuery: event.searchQuery,
        sortBy: event.sortBy,
        sortAscending: event.sortAscending,
        role: event.role,
        status: event.status,
        adminApprovalStatus: event.adminApprovalStatus,
        isArchived: event.isArchived,
      ),
    );
    print('bloc: ${event.sortBy}');

    print(response);

    response.fold((l) {
      emit(UsersError(message: l.message));
      print('Error loading users: ${l.message}');
    }, (r) {
      emit(
        UsersLoaded(
          users: r.users,
          totalUserCount: r.totalUserCount,
        ),
      );
      print(
          'Loaded users for page ${event.page}: ${r.users.length}, total count: ${r.totalUserCount}');
    });
  }

  void _onFetchPendingUsers(
      FetchPendingUsersEvent event,
      Emitter<UsersManagementState> emit,
      ) async {
    emit(PendingUsersLoading());

    final response = await _getPendingUsers(
      GetPendingUsersParams(
        page: event.page,
        pageSize: event.pageSize,
      ),
    );

    response.fold((l) {
      emit(PendingUsersError(message: l.message));
      print('Error loading users: ${l.message}');
    }, (r) {
      emit(
        PendingUsersLoaded(
          users: r.users,
          totalUserCount: r.totalUserCount,
        ),
      );
      print(
          'Loaded users for page ${event.page}: ${r.users.length}, total count: ${r.totalUserCount}');
    });
  }

  void _onUpdateUserAuth(
    UpdateUserAuthenticationStatusEvent event,
    Emitter<UsersManagementState> emit,
  ) async {
    emit(UsersLoading());

    print('bloc data: ${event.authStatus}');

    final response = await _updateUserAuthStatus(
      UpdateUserAuthStatusParams(
        id: event.userId,
        authStatus: event.authStatus,
      ),
    );

    response.fold(
      (l) {
        print('Error updating user auth status: ${l.message}');
        emit(UsersError(message: l.message));
      },
      (r) {
        print('User auth status updated successfully: $r');
        emit(UserAuthenticationStatusUpdated(isSuccessful: r));
      },
    );
  }

  void _onUpdateArchiveStatus(
    UpdateArchiveStatusEvent event,
    Emitter<UsersManagementState> emit,
  ) async {
    emit(UsersLoading());

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
        emit(UsersError(message: l.message));
      },
      (r) {
        print('User archive status updated successfully: $r');
        emit(UserArchiveStatusUpdated(isSuccessful: r));
      },
    );
  }

  void _onUpdateAdminApprovalStatus(
    UpdateAdminApprovalStatusEvent event,
    Emitter<UsersManagementState> emit,
  ) async {
    emit(PendingUsersLoading());

    final response = await _updateAdminApprovalStatus(
      UpdateAdminApprovalStatusParams(
        id: event.userId,
        adminApprovalStatus: event.adminApprovalStatus,
      ),
    );

    response.fold(
      (l) {
        print('Error updating user admin approval status: ${l.message}');
        emit(PendingUsersError(message: l.message));
      },
      (r) {
        print('User admin approval status updated successfully: $r');
        emit(AdminApprovalStatusUpdated(isSuccessful: r));
      },
    );
  }
}
