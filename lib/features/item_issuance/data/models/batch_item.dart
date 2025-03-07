import '../../../../core/enums/batch_status.dart';
import '../../domain/entities/batch_item.dart';

class BatchItemModel extends BatchItemEntity {
  const BatchItemModel({
    required super.id,
    required super.baseItemId,
    required super.batchCode,
    super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory BatchItemModel.fromJson(Map<String, dynamic> json) {
    return BatchItemModel(
      id: json['id'],
      baseItemId: json['base_item_id'],
      batchCode: json['batch_code'],
      status: BatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_item_id': baseItemId,
      'batch_code': batchCode,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
