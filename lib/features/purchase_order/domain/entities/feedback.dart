class FeedbackEntity {
  const FeedbackEntity({
    required this.feedback,
    this.isIncrease,
    required this.percentage,
  });

  final String feedback;
  final bool? isIncrease;
  final double percentage;
}
