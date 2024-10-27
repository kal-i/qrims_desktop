part of 'users_management_bloc.dart';

sealed class UsersManagementEvent extends Equatable {
  const UsersManagementEvent();

  @override
  List<Object?> get props => [];
}

final class FetchUsersEvent extends UsersManagementEvent {
  const FetchUsersEvent({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.sortBy,
    this.sortAscending,
    this.role,
    this.status,
    this.adminApprovalStatus,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final String? role;
  final AuthStatus? status;
  final AdminApprovalStatus? adminApprovalStatus;
  final bool? isArchived;
}

final class FetchPendingUsersEvent extends UsersManagementEvent {
  const FetchPendingUsersEvent({
    required this.page,
    required this.pageSize,
  });

  final int page;
  final int pageSize;
}

final class UpdateUserAuthenticationStatusEvent extends UsersManagementEvent {
  const UpdateUserAuthenticationStatusEvent({
    required this.userId,
    required this.authStatus,
  });

  final String userId;
  final AuthStatus authStatus;
}

final class UpdateArchiveStatusEvent extends UsersManagementEvent {
  const UpdateArchiveStatusEvent({
    required this.userId,
    required this.isArchived,
  });

  final String userId;
  final bool isArchived;
}

final class UpdateAdminApprovalStatusEvent extends UsersManagementEvent {
  const UpdateAdminApprovalStatusEvent({
    required this.userId,
    required this.adminApprovalStatus,
  });

  final String userId;
  final AdminApprovalStatus adminApprovalStatus;
}
