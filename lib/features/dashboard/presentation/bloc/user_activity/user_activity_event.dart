part of 'user_activity_bloc.dart';

sealed class UserActivityEvent extends Equatable {
  const UserActivityEvent();

  @override
  List<Object?> get props => [];
}

final class FetchUserActivities extends UserActivityEvent {
  const FetchUserActivities({
    required this.userId,
    required this.page,
    required this.pageSize,
  });

  final int userId;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [
        userId,
        page,
        pageSize,
      ];
}
