part of 'officers_bloc.dart';

sealed class OfficersEvent extends Equatable {
  const OfficersEvent();

  @override
  List<Object?> get props => [];
}

final class GetPaginatedOfficersEvent extends OfficersEvent {
  const GetPaginatedOfficersEvent({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.office,
    this.sortBy,
    this.status,
    this.sortAscending,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? office;
  final String? sortBy;
  final OfficerStatus? status;
  final bool? sortAscending;
  final bool? isArchived;

  @override
  List<Object?> get props => [
        page,
        pageSize,
        searchQuery,
        office,
        sortBy,
        sortAscending,
        isArchived,
      ];
}

final class RegisterOfficerEvent extends OfficersEvent {
  const RegisterOfficerEvent({
    required this.name,
    required this.officeName,
    required this.positionName,
  });

  final String name;
  final String officeName;
  final String positionName;

  @override
  List<Object?> get props => [
        name,
        positionName,
      ];
}

final class UpdateOfficerEvent extends OfficersEvent {
  const UpdateOfficerEvent({
    required this.id,
    this.office,
    this.position,
    this.name,
    this.status,
  });

  final String id;
  final String? office;
  final String? position;
  final String? name;
  final OfficerStatus? status;
}

final class UpdateOfficerArchiveStatusEvent extends OfficersEvent {
  const UpdateOfficerArchiveStatusEvent({
    required this.id,
    required this.isArchived,
  });

  final String id;
  final bool isArchived;
}
