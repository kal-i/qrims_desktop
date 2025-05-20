import '../../domain/entities/reusable_item_information.dart';

class ReusableItemInformationModel extends ReusableItemInformationEntity {
  const ReusableItemInformationModel({
    required super.productName,
    required super.productDescription,
    required super.specification,
    super.quantity,
  });

  factory ReusableItemInformationModel.fromJson(Map<String, dynamic> json) {
    print('received raw json by reusable item info $json');

    final reusableItemInfoModel = ReusableItemInformationModel(
      productName: json['product_name'],
      productDescription: json['product_description'],
      specification: json['specification'] as String?,
      quantity: json['quantity'] as int?,
    );

    print('reusable item converted');

    return reusableItemInfoModel;
  }
}
