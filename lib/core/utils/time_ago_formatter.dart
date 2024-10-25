String timeAgo(DateTime createdAt) {
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return '${years}y';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return '${months}m';
  } else if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w';
  } else if (difference.inDays > 0) {
    return '${difference.inDays}d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return '0d';
  }
}
