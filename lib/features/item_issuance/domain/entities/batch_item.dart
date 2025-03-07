import '../../../../core/enums/batch_status.dart';

class BatchItemEntity {
  const BatchItemEntity({
    required this.id,
    required this.baseItemId,
    required this.batchCode,
    this.status = BatchStatus.available,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String baseItemId;
  final String batchCode;
  final BatchStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
