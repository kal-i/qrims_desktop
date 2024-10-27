part of 'users_management_bloc.dart';

sealed class UsersManagementState extends Equatable {
  const UsersManagementState();

  @override
  List<Object?> get props => [];
}

final class UsersInitial extends UsersManagementState {}

final class UsersLoading extends UsersManagementState {}

final class UsersLoaded extends UsersManagementState {
  const UsersLoaded({
    required this.users,
    required this.totalUserCount,
  });

  final List<UserEntity> users;
  final int totalUserCount;

  @override
  List<Object?> get props => [
        users,
        totalUserCount,
      ];
}

final class UsersError extends UsersManagementState {
  const UsersError({
    required this.message,
  });

  final String message;
}

final class PendingUsersInitial extends UsersManagementState {}

final class PendingUsersLoading extends UsersManagementState {}

final class PendingUsersLoaded extends UsersManagementState {
  const PendingUsersLoaded({
    required this.users,
    required this.totalUserCount,
  });

  final List<MobileUserEntity> users;
  final int totalUserCount;

  @override
  List<Object?> get props => [
    users,
    totalUserCount,
  ];
}

final class PendingUsersError extends UsersManagementState {
  const PendingUsersError({
    required this.message,
  });

  final String message;
}

final class UserAuthenticationStatusUpdated extends UsersManagementState {
  const UserAuthenticationStatusUpdated({
    required this.isSuccessful,
  });

  final bool isSuccessful;

  @override
  List<Object?> get props => [
        isSuccessful,
      ];
}

final class UserArchiveStatusUpdated extends UsersManagementState {
  const UserArchiveStatusUpdated({
    required this.isSuccessful,
  });

  final bool isSuccessful;

  @override
  List<Object?> get props => [
    isSuccessful,
  ];
}

final class AdminApprovalStatusUpdated extends UsersManagementState {
  const AdminApprovalStatusUpdated({
    required this.isSuccessful,
  });

  final bool isSuccessful;

  @override
  List<Object?> get props => [
    isSuccessful,
  ];
}
