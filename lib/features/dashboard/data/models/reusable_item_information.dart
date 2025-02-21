import '../../domain/entities/reusable_item_information.dart';

class ReusableItemInformationModel extends ReusableItemInformationEntity {
  const ReusableItemInformationModel({
    required super.productName,
    required super.productDescription,
    required super.specifciation,
    super.quantity,
  });

  factory ReusableItemInformationModel.fromJson(Map<String, dynamic> json) {
    print('received raw json by reusable item info $json');

    final reusableItemInfoModel = ReusableItemInformationModel(
      productName: json['product_name'],
      productDescription: json['product_description'],
      specifciation: json['specification'],
      quantity: json['quantity'] as int?,
    );

    print('reusable item converted');

    return reusableItemInfoModel;
  }
}
