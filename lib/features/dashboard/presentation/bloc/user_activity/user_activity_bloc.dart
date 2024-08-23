import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_activity.dart';
import '../../../domain/usecases/get_user_activities.dart';

part 'user_activity_event.dart';
part 'user_activity_state.dart';

class UserActivityBloc extends Bloc<UserActivityEvent, UserActivityState> {
  UserActivityBloc({
    required GetUserActivities getUserActivities,
  })  : _getUserActivities = getUserActivities,
        super(UserActivityInitial()) {
    on<FetchUserActivities>(_onFetchUserActivities);
  }

  final GetUserActivities _getUserActivities;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isFetching = false;

  void _onFetchUserActivities(
    FetchUserActivities event,
    Emitter<UserActivityState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;

    final currentState = state;
    var oldActivities = <UserActivityEntity>[];

    if (currentState is UserActivityLoaded) {
      oldActivities = currentState.userActivities;
    }

    emit(UserActivityLoading(
        oldActivities: oldActivities, isFirstFetch: _currentPage == 1));

    final response = await _getUserActivities(
      GetUserActivitiesParams(
        userId: event.userId,
        page: event.page,
        pageSize: event.pageSize,
      ),
    );

    response.fold(
      (l) => emit(UserActivityError(message: l.message)),
      (r) {
        _currentPage++;
        final allActivities = oldActivities + r;
        emit(UserActivityLoaded(userActivities: allActivities));
      },
    );
  }

  void fetchNextPage(int userId) {
    add(FetchUserActivities(userId: userId, page: _currentPage, pageSize: _pageSize));
  }
}
