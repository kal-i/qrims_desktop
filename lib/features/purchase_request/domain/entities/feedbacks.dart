import 'feedback.dart';

class FeedbacksEntity {
  const FeedbacksEntity({
    required this.pending,
    required this.partiallyFulfilled,
    required this.fulfilled,
    required this.cancelled,
  });

  final FeedbackEntity pending;
  final FeedbackEntity partiallyFulfilled;
  final FeedbackEntity fulfilled;
  final FeedbackEntity cancelled;
}
