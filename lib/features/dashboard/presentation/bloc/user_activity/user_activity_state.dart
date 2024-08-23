part of 'user_activity_bloc.dart';

sealed class UserActivityState extends Equatable {
  const UserActivityState();

  @override
  List<Object?> get props => [];
}

final class UserActivityInitial extends UserActivityState {}

final class UserActivityLoading extends UserActivityState {
  const UserActivityLoading({
    required this.oldActivities,
    required this.isFirstFetch,
  });

  final List<UserActivityEntity> oldActivities;
  final bool isFirstFetch;

  @override
  List<Object?> get props => [
        oldActivities,
        isFirstFetch,
      ];
}

final class UserActivityLoaded extends UserActivityState {
  const UserActivityLoaded({
    required this.userActivities,
  });

  final List<UserActivityEntity> userActivities;

  @override
  List<Object?> get props => [
        userActivities,
      ];
}

final class UserActivityError extends UserActivityState {
  const UserActivityError({
    required this.message,
  });

  final String message;
}
