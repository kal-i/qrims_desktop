part of 'officers_bloc.dart';

sealed class OfficersState extends Equatable {
  const OfficersState();

  @override
  List<Object?> get props => [];
}

final class OfficersInitial extends OfficersState {}

final class OfficersLoading extends OfficersState {}

final class OfficersLoaded extends OfficersState {
  const OfficersLoaded({
    required this.officers,
    required this.totalOfficersCount,
  });

  final List<OfficerEntity> officers;
  final int totalOfficersCount;

  @override
  List<Object?> get props => [
        officers,
        totalOfficersCount,
      ];
}

final class OfficerRegistered extends OfficersState {
  const OfficerRegistered({
    required this.officer,
  });

  final OfficerEntity officer;
}

final class OfficersError extends OfficersState {
  const OfficersError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
        message,
      ];
}

final class OfficersArchiveStatusUpdated extends OfficersState {
  const OfficersArchiveStatusUpdated({
    required this.isSuccessful,
  });

  final bool isSuccessful;

  @override
  List<Object?> get props => [
        isSuccessful,
      ];
}
