part of 'archive_users_bloc.dart';

sealed class ArchiveUsersState extends Equatable {
  const ArchiveUsersState();

  @override
  List<Object?> get props => [];
}

final class ArchivedUsersInitial extends ArchiveUsersState {}

final class ArchivedUsersLoading extends ArchiveUsersState {}

final class ArchivedUsersLoaded extends ArchiveUsersState {
  const ArchivedUsersLoaded({
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

final class ArchivedUsersError extends ArchiveUsersState {
  const ArchivedUsersError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
    message,
  ];
}

final class UserArchiveStatusUpdated extends ArchiveUsersState {
  const UserArchiveStatusUpdated({
    required this.isSuccessful,
  });

  final bool isSuccessful;

  @override
  List<Object?> get props => [
    isSuccessful,
  ];
}