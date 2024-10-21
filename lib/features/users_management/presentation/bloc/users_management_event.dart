part of 'users_management_bloc.dart';

sealed class UsersManagementEvent extends Equatable {
  const UsersManagementEvent();

  @override
  List<Object?> get props => [];
}

final class FetchUsers extends UsersManagementEvent {
  const FetchUsers({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.sortBy,
    this.sortAscending,
    this.role,
    this.status,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final String? role;
  final AuthStatus? status;
  final bool? isArchived;
}

final class UpdateUserAuthenticationStatus extends UsersManagementEvent {
  const UpdateUserAuthenticationStatus({
    required this.userId,
    required this.authStatus,
  });

  final String userId;
  final AuthStatus authStatus;
}

final class UpdateArchiveStatus extends UsersManagementEvent {
  const UpdateArchiveStatus({
    required this.userId,
    required this.isArchived,
  });

  final String userId;
  final bool isArchived;
}
