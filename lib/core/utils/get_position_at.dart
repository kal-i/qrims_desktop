import '../../features/officer/domain/entities/officer.dart';
import '../../features/officer/domain/entities/position_history.dart';

extension OfficerEntityX on OfficerEntity {
  PositionHistoryEntity? getPositionAt(DateTime date) {
    // Make sure position history is sorted by createdAt ascending
    final sortedHistory = List<PositionHistoryEntity>.from(positionHistory)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Filter out all history records that occurred before or on the date
    final validPositions = sortedHistory
        .where((p) =>
            p.createdAt.isBefore(date) || p.createdAt.isAtSameMomentAs(date))
        .toList();

    // The last one before or on the date is the valid one
    return validPositions.isNotEmpty ? validPositions.last : null;
  }
}
