import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/enums/auth_status.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/update_user_auth_status.dart';

part 'users_management_event.dart';
part 'users_management_state.dart';

class UsersManagementBloc
    extends Bloc<UsersManagementEvent, UsersManagementState> {
  UsersManagementBloc({
    required GetUsers getUsers,
    required UpdateUserAuthStatus updateUserAuthStatus,
  })  : _getUsers = getUsers,
        _updateUserAuthStatus = updateUserAuthStatus,
        super(UsersInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<UpdateUserAuthenticationStatus>(_onUpdateUserAuth);
  }

  final GetUsers _getUsers;
  final UpdateUserAuthStatus _updateUserAuthStatus;

  void _onFetchUsers(
    FetchUsers event,
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
        filter: event.filter,
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

  void _onUpdateUserAuth(
    UpdateUserAuthenticationStatus event,
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
}
