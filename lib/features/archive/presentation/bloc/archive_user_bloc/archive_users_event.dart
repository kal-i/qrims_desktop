part of 'archive_users_bloc.dart';

sealed class ArchiveUsersEvent extends Equatable {
  const ArchiveUsersEvent();

  @override
  List<Object?> get props => [];
}

final class GetArchivedUsersEvent extends ArchiveUsersEvent {
  const GetArchivedUsersEvent({
    required this.page,
    required this.pageSize,
    required this.searchQuery,
    required this.role,
    required this.authStatus,
    required this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? role;
  final AuthStatus? authStatus;
  final bool isArchived;

  @override
  List<Object?> get props => [
    page,
    pageSize,
    searchQuery,
    role,
    authStatus,
    isArchived,
  ];
}

final class UpdateUserArchiveStatusEvent extends ArchiveUsersEvent {
  const UpdateUserArchiveStatusEvent({
    required this.userId,
    required this.isArchived,
  });

  final String userId;
  final bool isArchived;

  @override
  List<Object?> get props => [
    userId,
    isArchived,
  ];
}
