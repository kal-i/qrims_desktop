import 'package:api/src/item/models/item.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';

import '../../organization_management/models/officer.dart';

enum FundCluster {
  depEDCentralOffice,
  depEDRegionalOffice,
  depEDDivisionOffice,
  depEDImplementingUnit,
  donatedByLGU,
  donatedByOtherEntity,
  assetIsOwnedByLGU,
  assetIsOwnedByOtherEntity,
  assetIsLeased,
}

class IssuanceItem {
  const IssuanceItem({
    required this.issuanceId,
    required this.item,
    required this.quantity,
  });

  final String issuanceId;
  final ItemWithStock item;
  final int quantity;

  factory IssuanceItem.fromJson(Map<String, dynamic> json) {
    final item = ItemWithStock.fromJson(json['item'] as Map<String, dynamic>);

    return IssuanceItem(
      issuanceId: json['issuance_id'] as String,
      item: item,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issuance_id': issuanceId,
      'item': item.toJson(),
      'quantity': quantity,
    };
  }
}

/// Represents an abstract entity base class for issuance
abstract class Issuance {
  const Issuance({
    required this.id,
    required this.items,
    required this.purchaseRequest,
    required this.receivingOfficer,
    required this.issuedDate,
    this.returnDate,
    required this.qrCodeImageData,
    this.isReceived = false,
    this.isArchived = false,
  });

  final String id;
  final List<IssuanceItem> items;
  final PurchaseRequest purchaseRequest;
  final Officer receivingOfficer;
  final DateTime issuedDate;
  final DateTime? returnDate;
  final String qrCodeImageData;
  final bool isReceived; // represents if the receiving officer has received the item
  final bool isArchived;
}

/// ics
/// ics no: sphv-yyyy-mm-n
/// ris no: yyyy-mm-n
/// par no: yyyy-mm-n
/// y represents the year
/// m for month
/// n for the no. of ris for that month
///
/// we need to get the last no. in the table and increment it by one
/// this will reset back when a new month arrives

/// should I extend it or just create a field for it?
/// Concrete entity of issuance
class InventoryCustodianSlip extends Issuance {
  const InventoryCustodianSlip({
    required super.id, // refer to the parent/ issuance id
    required this.icsId,
    required super.items,
    required super.issuedDate,
    super.returnDate,
    required super.purchaseRequest,
    required super.receivingOfficer,
    required this.sendingOfficer,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  final String icsId;
  final Officer sendingOfficer; // represents the receive from

  factory InventoryCustodianSlip.fromJson(Map<String, dynamic> json) {
    final prJson = json['purchase_request'];

    final items = (json['items'] as List<dynamic>).map((itemJson) {
      final productStockData = {
        'product_name_id': itemJson['item']['product_stock']['product_name']
            ['product_name_id'],
        'product_name': itemJson['item']['product_stock']['product_name']
            ['product_name'],
        'product_description_id': itemJson['item']['product_stock']
            ['product_description']['product_description_id'],
        'product_description': itemJson['item']['product_stock']
            ['product_description']['product_description'],
      };

      final itemData = {
        'item_id': itemJson['item']['item']['item_id'],
        'product_name_id': itemJson['item']['item']['product_name_id'],
        'product_description_id': itemJson['item']['item']
            ['product_description_id'],
        'manufacturer_id': itemJson['item']['item']['manufacturer_id'],
        'brand_id': itemJson['item']['item']['brand_id'],
        'model_id': itemJson['item']['item']['model_id'],
        'serial_no': itemJson['item']['item']['serial_no'],
        'specification': itemJson['item']['item']['specification'],
        'asset_classification': itemJson['item']['item']
            ['asset_classification'],
        'asset_sub_class': itemJson['item']['item']['asset_sub_class'],
        'unit': itemJson['item']['item']['unit'],
        'quantity': itemJson['item']['item']['quantity'],
        'unit_cost': itemJson['item']['item']['unit_cost'],
        'estimated_useful_life':
            itemJson['item']['item']['estimated_useful_life'] as int,
        'acquired_date': itemJson['item']['item']['acquired_date'] is String
            ? DateTime.parse(
                itemJson['item']['item']['acquired_date'] as String)
            : itemJson['item']['item']['acquired_date'] as DateTime,
        'encrypted_id': itemJson['item']['item']['encrypted_id'],
        'qr_code_image_data': itemJson['item']['item']['qr_code_image_data'],
        'product_name': itemJson['item']['product_stock']['product_name']
            ['product_name'],
        'product_description': itemJson['item']['product_stock']
            ['product_description']['product_description'],
        'manufacturer_name': itemJson['item']['manufacturer_brand']
            ['manufacturer']['manufacturer_name'],
        'brand_name': itemJson['item']['manufacturer_brand']['brand']
            ['brand_name'],
        'model_name': itemJson['item']['model']['model_name'],
      };

      final manufacturerBrandData = {
        'manufacturer_id': itemJson['item']['manufacturer_brand']
            ['manufacturer']['manufacturer_id'],
        'manufacturer_name': itemJson['item']['manufacturer_brand']
            ['manufacturer']['manufacturer_name'],
        'brand_id': itemJson['item']['manufacturer_brand']['brand']['brand_id'],
        'brand_name': itemJson['item']['manufacturer_brand']['brand']
            ['brand_name'],
      };

      final modelData = {
        'model_id': itemJson['item']['model']['model_id'],
        'product_name_id': itemJson['item']['model']['product_name_id'],
        'brand_id': itemJson['item']['model']['brand_id'],
        'model_name': itemJson['item']['model']['model_name'],
      };

      // final item = ItemWithStock.fromJson({
      //   ...productStockData,
      //   ...itemData,
      //   ...manufacturerBrandData,
      //   ...modelData,
      // });
      // print('item: $item');

      final issuanceItem = IssuanceItem.fromJson({
        'issuance_id': itemJson['issuance_id'],
        'item': itemData,
        'quantity': itemJson['quantity'],
      });

      return issuanceItem;
    }).toList();
    print('return items: $items');

    final purchaseRequest = PurchaseRequest.fromJson({
      'id': prJson['id'],
      'entity_id': prJson['entity']['entity_id'],
      'entity_name': prJson['entity']['entity_name'],
      'fund_cluster': prJson['fund_cluster'],
      'office_id': prJson['office']['office_id'],
      'office_name': prJson['office']['office_name'],
      'responsibility_center_code': prJson['responsibility_center_code'],
      'date': prJson['date'],
      'product_name_id': prJson['product_name']['product_name_id'],
      'product_name': prJson['product_name']['product_name'],
      'product_description_id': prJson['product_description']
          ['product_description_id'],
      'product_description': prJson['product_description']
          ['product_description'],
      'unit': prJson['unit'],
      'quantity': prJson['quantity'],
      'remaining_quantity': prJson['remaining_quantity'],
      'unit_cost': prJson['unit_cost'],
      'total_cost': prJson['total_cost'],
      'purpose': prJson['purpose'],
      'requesting_officer_id': prJson['requesting_officer']['id'],
      'requesting_officer_user_id': prJson['requesting_officer']['user_id'],
      'requesting_officer_name': prJson['requesting_officer']['name'],
      'requesting_officer_position_id': prJson['requesting_officer']
          ['position_id'],
      'requesting_officer_office_name': prJson['requesting_officer']
          ['office_name'],
      'requesting_officer_position_name': prJson['requesting_officer']
          ['position_name'],
      'requesting_officer_is_archived': prJson['requesting_officer']
          ['is_archived'],
      'approving_officer_id': prJson['approving_officer']['id'],
      'approving_officer_user_id': prJson['approving_officer']['user_id'],
      'approving_officer_name': prJson['approving_officer']['name'],
      'approving_officer_position_id': prJson['approving_officer']
          ['position_id'],
      'approving_officer_office_name': prJson['approving_officer']
          ['office_name'],
      'approving_officer_position_name': prJson['approving_officer']
          ['position_name'],
      'approving_officer_is_archived': prJson['approving_officer']
          ['is_archived'],
      'status': prJson['status'],
      'is_archived': prJson['is_archived'],
    });
    print('return pr: $purchaseRequest');

    final receivingOfficer =
        Officer.fromJson(json['receiving_officer'] as Map<String, dynamic>);
    print('return receiving off: $receivingOfficer');

    final sendingOfficer =
        Officer.fromJson(json['sending_officer'] as Map<String, dynamic>);
    print('return sending off: $sendingOfficer');

    return InventoryCustodianSlip(
      id: json['id'] as String,
      icsId: json['ics_id'] as String,
      items: items,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null && json['return_date'] is String
          ? DateTime.tryParse(json['return_date'] as String)
          : json['return_date'] as DateTime?,
      purchaseRequest: purchaseRequest,
      receivingOfficer: receivingOfficer,
      sendingOfficer: sendingOfficer,
      qrCodeImageData: json['qr_code_image_data'] as String,
      isReceived: json['is_received'] as bool,
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ics_id': icsId,
      'items': items.map((item) => item.toJson()).toList(),
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'purchase_request': purchaseRequest.toJson(),
      'receiving_officer': receivingOfficer.toJson(),
      'sending_officer': sendingOfficer.toJson(),
      'qr_code_image_data': qrCodeImageData,
      'is_received': isReceived,
      'is_archived': isArchived,
    };
  }
}

// when items are return, then just create another issuance doc?

class PropertyAcknowledgementReceipt extends Issuance {
  const PropertyAcknowledgementReceipt({
    required super.id, // refer to the parent/ issuance id
    required this.parId,
    required this.propertyNumber,
    required super.items,
    required super.issuedDate,
    super.returnDate,
    required super.purchaseRequest,
    required super.receivingOfficer,
    required this.sendingOfficer,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  final String parId;
  final String? propertyNumber; // need some clarification in regards to this
  final Officer sendingOfficer;

  factory PropertyAcknowledgementReceipt.fromJson(Map<String, dynamic> json) {
    final prJson = json['purchase_request'];

    final items = (json['items'] as List<dynamic>).map((itemJson) {
      final productStockData = {
        'product_name_id': itemJson['item']['product_stock']['product_name']
        ['product_name_id'],
        'product_name': itemJson['item']['product_stock']['product_name']
        ['product_name'],
        'product_description_id': itemJson['item']['product_stock']
        ['product_description']['product_description_id'],
        'product_description': itemJson['item']['product_stock']
        ['product_description']['product_description'],
      };

      final itemData = {
        'item_id': itemJson['item']['item']['item_id'],
        'product_name_id': itemJson['item']['item']['product_name_id'],
        'product_description_id': itemJson['item']['item']
        ['product_description_id'],
        'manufacturer_id': itemJson['item']['item']['manufacturer_id'],
        'brand_id': itemJson['item']['item']['brand_id'],
        'model_id': itemJson['item']['item']['model_id'],
        'serial_no': itemJson['item']['item']['serial_no'],
        'specification': itemJson['item']['item']['specification'],
        'asset_classification': itemJson['item']['item']
        ['asset_classification'],
        'asset_sub_class': itemJson['item']['item']['asset_sub_class'],
        'unit': itemJson['item']['item']['unit'],
        'quantity': itemJson['item']['item']['quantity'],
        'unit_cost': itemJson['item']['item']['unit_cost'],
        'estimated_useful_life':
        itemJson['item']['item']['estimated_useful_life'] as int,
        'acquired_date': itemJson['item']['item']['acquired_date'] is String
            ? DateTime.parse(
            itemJson['item']['item']['acquired_date'] as String)
            : itemJson['item']['item']['acquired_date'] as DateTime,
        'encrypted_id': itemJson['item']['item']['encrypted_id'],
        'qr_code_image_data': itemJson['item']['item']['qr_code_image_data'],
        'product_name': itemJson['item']['product_stock']['product_name']
        ['product_name'],
        'product_description': itemJson['item']['product_stock']
        ['product_description']['product_description'],
        'manufacturer_name': itemJson['item']['manufacturer_brand']
        ['manufacturer']['manufacturer_name'],
        'brand_name': itemJson['item']['manufacturer_brand']['brand']
        ['brand_name'],
        'model_name': itemJson['item']['model']['model_name'],
      };

      final manufacturerBrandData = {
        'manufacturer_id': itemJson['item']['manufacturer_brand']
        ['manufacturer']['manufacturer_id'],
        'manufacturer_name': itemJson['item']['manufacturer_brand']
        ['manufacturer']['manufacturer_name'],
        'brand_id': itemJson['item']['manufacturer_brand']['brand']['brand_id'],
        'brand_name': itemJson['item']['manufacturer_brand']['brand']
        ['brand_name'],
      };

      final modelData = {
        'model_id': itemJson['item']['model']['model_id'],
        'product_name_id': itemJson['item']['model']['product_name_id'],
        'brand_id': itemJson['item']['model']['brand_id'],
        'model_name': itemJson['item']['model']['model_name'],
      };

      // final item = ItemWithStock.fromJson({
      //   ...productStockData,
      //   ...itemData,
      //   ...manufacturerBrandData,
      //   ...modelData,
      // });
      // print('item: $item');

      final issuanceItem = IssuanceItem.fromJson({
        'issuance_id': itemJson['issuance_id'],
        'item': itemData,
        'quantity': itemJson['quantity'],
      });

      return issuanceItem;
    }).toList();
    print('return items: $items');

    final purchaseRequest = PurchaseRequest.fromJson({
      'id': prJson['id'],
      'entity_id': prJson['entity']['entity_id'],
      'entity_name': prJson['entity']['entity_name'],
      'fund_cluster': prJson['fund_cluster'],
      'office_id': prJson['office']['office_id'],
      'office_name': prJson['office']['office_name'],
      'responsibility_center_code': prJson['responsibility_center_code'],
      'date': prJson['date'],
      'product_name_id': prJson['product_name']['product_name_id'],
      'product_name': prJson['product_name']['product_name'],
      'product_description_id': prJson['product_description']
      ['product_description_id'],
      'product_description': prJson['product_description']
      ['product_description'],
      'unit': prJson['unit'],
      'quantity': prJson['quantity'],
      'remaining_quantity': prJson['remaining_quantity'],
      'unit_cost': prJson['unit_cost'],
      'total_cost': prJson['total_cost'],
      'purpose': prJson['purpose'],
      'requesting_officer_id': prJson['requesting_officer']['id'],
      'requesting_officer_user_id': prJson['requesting_officer']['user_id'],
      'requesting_officer_name': prJson['requesting_officer']['name'],
      'requesting_officer_position_id': prJson['requesting_officer']
      ['position_id'],
      'requesting_officer_office_name': prJson['requesting_officer']
      ['office_name'],
      'requesting_officer_position_name': prJson['requesting_officer']
      ['position_name'],
      'requesting_officer_is_archived': prJson['requesting_officer']
      ['is_archived'],
      'approving_officer_id': prJson['approving_officer']['id'],
      'approving_officer_user_id': prJson['approving_officer']['user_id'],
      'approving_officer_name': prJson['approving_officer']['name'],
      'approving_officer_position_id': prJson['approving_officer']
      ['position_id'],
      'approving_officer_office_name': prJson['approving_officer']
      ['office_name'],
      'approving_officer_position_name': prJson['approving_officer']
      ['position_name'],
      'approving_officer_is_archived': prJson['approving_officer']
      ['is_archived'],
      'status': prJson['status'],
      'is_archived': prJson['is_archived'],
    });
    print('return pr: $purchaseRequest');

    final receivingOfficer =
    Officer.fromJson(json['receiving_officer'] as Map<String, dynamic>);
    print('return receiving off: $receivingOfficer');

    final sendingOfficer =
    Officer.fromJson(json['sending_officer'] as Map<String, dynamic>);
    print('return sending off: $sendingOfficer');

    return PropertyAcknowledgementReceipt(
      id: json['id'] as String,
      parId: json['par_id'] as String,
      propertyNumber: json['property_number'] as String?,
      items: items,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null && json['return_date'] is String
          ? DateTime.tryParse(json['return_date'] as String)
          : json['return_date'] as DateTime?,
      purchaseRequest: purchaseRequest,
      receivingOfficer: receivingOfficer,
      sendingOfficer: sendingOfficer,
      qrCodeImageData: json['qr_code_image_data'] as String,
      isReceived: json['is_received'] as bool,
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'par_id': parId,
      'property_number': propertyNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'purchase_request': purchaseRequest.toJson(),
      'receiving_officer': receivingOfficer.toJson(),
      'sending_officer': sendingOfficer.toJson(),
      'qr_code_image_data': qrCodeImageData,
      'is_received': isReceived,
      'is_archived': isArchived,
    };
  }
}
//
// class RequisitionSlip extends Issuance {
//   const RequisitionSlip({
//     required super.id, // refer to the parent/ issuance id
//     required super.entityId,
//     required super.fundClusterId,
//     required super.quantity,
//     required super.receivingOfficerId,
//     required super.issuedDate,
//     required super.purchaseRequestId,
//   });
//
//   final String risId;
//   final String divisionId;
//   final String responsibilityCenterCode;
//   final String officeId;
//   final String itemId;
//   final bool isStockAvailable;
//   final int quantityLeft;
//   final String remarks;
//   final String purpose;
//   final String requestingOfficerId;
//   final String approvingOfficerId;
//   final String issuingOfficerId;
// }
