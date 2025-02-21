import 'package:api/src/item/models/item.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';

import '../../organization_management/models/officer.dart';
import '../../organization_management/models/position_history.dart';

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
  unknown,
}

class IssuanceItem {
  const IssuanceItem({
    required this.issuanceId,
    required this.item,
    required this.quantity,
  });

  final String issuanceId;
  final BaseItemModel item;
  final int quantity;

  factory IssuanceItem.fromJson(Map<String, dynamic> json) {
    try {
      print('raw json received by issuance item: $json');

      // Check if 'item' exists in the JSON
      if (json['item'] == null) {
        throw Exception("'item' field is missing in the JSON");
      }

      // Handle both list and single object cases for 'item'
      final itemJson = json['item'] is List ? json['item'][0] : json['item'];
      print('issuance item received: $itemJson');

      // Check if required fields are present
      if (itemJson['shareable_item_information'] == null) {
        throw Exception(
            "'shareable_item_information' is missing in the item JSON");
      }

      // Re-mapping
      final itemData = itemJson['supply_id'] != null
          ? {
              'supply_id': itemJson['supply_id'] as int?,
              'base_item_id': itemJson['shareable_item_information']
                  ['base_item_id'],
              'product_name_id': itemJson['product_stock']['product_name']
                  ['product_name_id'],
              'product_name': itemJson['product_stock']['product_name']
                  ['product_name'],
              'product_description_id': itemJson['product_stock']
                  ['product_description']['product_description_id'],
              'product_description': itemJson['product_stock']
                  ['product_description']['product_description'],
              'specification': itemJson['shareable_item_information']
                  ['specification'],
              'unit': itemJson['shareable_item_information']['unit'],
              'quantity': itemJson['shareable_item_information']['quantity'],
              'unit_cost': itemJson['shareable_item_information']['unit_cost'],
              'encrypted_id': itemJson['shareable_item_information']
                  ['encrypted_id'],
              'qr_code_image_data': itemJson['shareable_item_information']
                  ['qr_code_image_data'],
              'acquired_date': itemJson['shareable_item_information']
                  ['acquired_date'],
            }
          : {
              'equipment_id': itemJson['equipment_id'] as int?,
              'base_item_id': itemJson['shareable_item_information']
                  ['base_item_id'],
              'product_name_id': itemJson['product_stock']['product_name']
                  ['product_name_id'],
              'product_name': itemJson['product_stock']['product_name']
                  ['product_name'],
              'product_description_id': itemJson['product_stock']
                  ['product_description']['product_description_id'],
              'product_description': itemJson['product_stock']
                  ['product_description']['product_description'],
              'specification': itemJson['shareable_item_information']
                  ['specification'],
              'unit': itemJson['shareable_item_information']['unit'],
              'quantity': itemJson['shareable_item_information']['quantity'],
              'unit_cost': itemJson['shareable_item_information']['unit_cost'],
              'encrypted_id': itemJson['shareable_item_information']
                  ['encrypted_id'],
              'qr_code_image_data': itemJson['shareable_item_information']
                  ['qr_code_image_data'],
              'acquired_date': itemJson['shareable_item_information']
                  ['acquired_date'],
              'manufacturer_id': itemJson['manufacturer_brand']['manufacturer']
                  ['manufacturer_id'] as String?,
              'manufacturer_name': itemJson['manufacturer_brand']
                  ['manufacturer']['manufacturer_name'] as String?,
              'brand_id': itemJson['manufacturer_brand']['brand']['brand_id']
                  as String?,
              'brand_name': itemJson['manufacturer_brand']['brand']
                  ['brand_name'] as String?,
              'model_id': itemJson['model']['model_id'] as String?,
              'model_name': itemJson['model']['model_name'] as String?,
              'serial_no': itemJson['serial_no'] as String?,
              'asset_classification':
                  itemJson['asset_classification'] as String?,
              'asset_sub_class': itemJson['asset_sub_class'] as String?,
              'estimated_useful_life':
                  itemJson['estimated_useful_life'] as int?,
            };

      print('item data: $itemData');

      final item = BaseItemModel.fromJson(itemData);
      print('item obj: $item');

      return IssuanceItem(
        issuanceId: json['issuance_id'] as String,
        item: item,
        quantity: json['issued_quantity'] as int,
      );
    } catch (e) {
      print('Error parsing IssuanceItem from JSON: $e');
      rethrow; // Re-throw the exception after logging it
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'issuance_id': issuanceId,
      'item': item is Supply
          ? (item as Supply).toJson()
          : (item as Equipment).toJson(),
      'issued_quantity': quantity,
    };
  }
}

/// Represents an abstract entity base class for issuance
/// Todos: make pr and receiving officer  nullable and update the table schema
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
  final bool
      isReceived; // represents if the receiving officer has received the item
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
    print('received raw json by ics: $json'); //
    final prJson = json['purchase_request'];

    final items = (json['items'] as List<dynamic>).map((itemJson) {
      print('item json: $itemJson'); //
      final itemData = itemJson['item']['supply_id'] != null
          ? {
              'supply_id': itemJson['item']['supply_id'],
              'equipment_id': itemJson['item']['equipment_id'],
              'shareable_item_information': {
                'base_item_id': itemJson['item']['shareable_item_information']
                    ['base_item_id'],
                'specification': itemJson['item']['shareable_item_information']
                    ['specification'],
                'unit': itemJson['item']['shareable_item_information']['unit'],
                'quantity': itemJson['item']['shareable_item_information']
                    ['quantity'],
                'unit_cost': itemJson['item']['shareable_item_information']
                    ['unit_cost'],
                'encrypted_id': itemJson['item']['shareable_item_information']
                    ['encrypted_id'],
                'qr_code_image_data': itemJson['item']
                    ['shareable_item_information']['qr_code_image_data'],
                'acquired_date': itemJson['item']['shareable_item_information']
                    ['acquired_date'],
              },
              'product_stock': {
                'product_name': {
                  'product_name_id': itemJson['item']['product_stock']
                      ['product_name']['product_name_id'],
                  'product_name': itemJson['item']['product_stock']
                      ['product_name']['product_name'],
                },
                'product_description': {
                  'product_description_id': itemJson['item']['product_stock']
                      ['product_description']['product_description_id'],
                  'product_description': itemJson['item']['product_stock']
                      ['product_description']['product_description'],
                },
              },
            }
          : {
              'equipment_id': itemJson['item']['equipment_id'],
              'shareable_item_information': {
                'base_item_id': itemJson['item']['shareable_item_information']
                    ['base_item_id'],
                'specification': itemJson['item']['shareable_item_information']
                    ['specification'],
                'unit': itemJson['item']['shareable_item_information']['unit'],
                'quantity': itemJson['item']['shareable_item_information']
                    ['quantity'],
                'unit_cost': itemJson['item']['shareable_item_information']
                    ['unit_cost'],
                'encrypted_id': itemJson['item']['shareable_item_information']
                    ['encrypted_id'],
                'qr_code_image_data': itemJson['item']
                    ['shareable_item_information']['qr_code_image_data'],
                'acquired_date': itemJson['item']['shareable_item_information']
                    ['acquired_date'],
              },
              'product_stock': {
                'product_name': {
                  'product_name_id': itemJson['item']['product_stock']
                      ['product_name']['product_name_id'],
                  'product_name': itemJson['item']['product_stock']
                      ['product_name']['product_name'],
                },
                'product_description': {
                  'product_description_id': itemJson['item']['product_stock']
                      ['product_description']['product_description_id'],
                  'product_description': itemJson['item']['product_stock']
                      ['product_description']['product_description'],
                },
              },
              'manufacturer_brand': {
                'manufacturer': {
                  'manufacturer_id': itemJson['item']['manufacturer_brand']
                      ['manufacturer']['manufacturer_id'],
                  'manufacturer_name': itemJson['item']['manufacturer_brand']
                      ['manufacturer']['manufacturer_name'],
                },
                'brand': {
                  'brand_id': itemJson['item']['manufacturer_brand']['brand']
                      ['brand_id'],
                  'brand_name': itemJson['item']['manufacturer_brand']['brand']
                      ['brand_name'],
                },
              },
              'model': {
                'model_id': itemJson['item']['model']['model_id'],
                'model_name': itemJson['item']['model']['model_name'],
              },
              'serial_no': itemJson['item']['serial_no'],
              'asset_classification': itemJson['item']['asset_classification'],
              'asset_sub_class': itemJson['item']['asset_sub_class'],
              'estimated_useful_life': itemJson['item']
                  ['estimated_useful_life'],
            };

      final issuanceItem = IssuanceItem.fromJson({
        'issuance_id': itemJson['issuance_id'],
        'item': itemData,
        'issued_quantity': itemJson['issued_quantity'],
      });

      return issuanceItem;
    }).toList();

    print('issuance items converted');

    final requestedItems = (prJson['requested_items'] as List<dynamic>)
        .map((requestedItem) => RequestedItem.fromJson({
              'id': requestedItem['id'],
              'pr_id': requestedItem['pr_id'],
              'product_name_id': requestedItem['product_name']
                  ['product_name_id'],
              'product_name': requestedItem['product_name']['product_name'],
              'product_description_id': requestedItem['product_description']
                  ['product_description_id'],
              'product_description': requestedItem['product_description']
                  ['product_description'],
              'specification': requestedItem['specification'],
              'unit': requestedItem['unit'],
              'quantity': requestedItem['quantity'],
              'remaining_quantity': requestedItem['remaining_quantity'],
              'unit_cost': requestedItem['unit_cost'],
              'total_cost': requestedItem['total_cost'],
              'status': requestedItem['status'],
            }).toJson())
        .toList();

    print('requested items converted');

    final requestingOfficerJson = prJson['requesting_officer'];
    final requestingOfficerData = {
      'id': requestingOfficerJson['id'],
      'user_id': requestingOfficerJson['user_id'],
      'name': requestingOfficerJson['name'],
      'position_id': requestingOfficerJson['position_id'],
      'office_name': requestingOfficerJson['office_name'],
      'position_name': requestingOfficerJson['position_name'],
      'position_history':
          (requestingOfficerJson['position_history'] as List<dynamic>)
              .map((position) {
        print('position: $position');
        return PositionHistory.fromJson({
          'id': position['id'],
          'officer_id': position['officer_id'],
          'position_id': position['position_id'],
          'office_name': position['office_name'],
          'position_name': position['position_name'],
          'created_at': position['created_at'],
        }).toJson();
      }).toList(),
      'status': requestingOfficerJson['status'],
      'is_archived': requestingOfficerJson['is_archived'],
    };

    print('requesting officer converted');

    final approvingOfficerJson = prJson['approving_officer'];
    final approvingOfficerData = {
      'id': approvingOfficerJson['id'],
      'user_id': approvingOfficerJson['user_id'],
      'name': approvingOfficerJson['name'],
      'position_id': approvingOfficerJson['position_id'],
      'office_name': approvingOfficerJson['office_name'],
      'position_name': approvingOfficerJson['position_name'],
      'position_history':
          (approvingOfficerJson['position_history'] as List<dynamic>)
              .map((position) {
        return PositionHistory.fromJson({
          'id': position['id'],
          'officer_id': position['officer_id'],
          'position_id': position['position_id'],
          'office_name': position['office_name'],
          'position_name': position['position_name'],
          'created_at': position['created_at'],
        }).toJson();
      }).toList(),
      'status': approvingOfficerJson['status'],
      'is_archived': approvingOfficerJson['is_archived'],
    };

    print('approving officer converted');

    final purchaseRequest = PurchaseRequest.fromJson({
      'id': prJson['id'],
      'entity_id': prJson['entity']['entity_id'],
      'entity_name': prJson['entity']['entity_name'],
      'fund_cluster': prJson['fund_cluster'],
      'office_id': prJson['office']['office_id'],
      'office_name': prJson['office']['office_name'],
      'responsibility_center_code': prJson['responsibility_center_code'],
      'date': prJson['date'],
      'requested_items': requestedItems,
      'purpose': prJson['purpose'],
      'requesting_officer': requestingOfficerData,
      'approving_officer': approvingOfficerData,
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
  final Officer sendingOfficer;

  factory PropertyAcknowledgementReceipt.fromJson(Map<String, dynamic> json) {
    final prJson = json['purchase_request'];

    print('json received by par: $json');
    print('items json received by par: ${json['items']}');

    final items = (json['items'] as List<dynamic>).map((itemJson) {
      print('item json: $itemJson');
      final itemData = itemJson['item']['supply_id'] != null
          ? {
              'supply_id': itemJson['item']['supply_id'],
              'equipment_id': itemJson['item']['equipment_id'],
              'shareable_item_information': {
                'base_item_id': itemJson['item']['shareable_item_information']
                    ['base_item_id'],
                'specification': itemJson['item']['shareable_item_information']
                    ['specification'],
                'unit': itemJson['item']['shareable_item_information']['unit'],
                'quantity': itemJson['item']['shareable_item_information']
                    ['quantity'],
                'unit_cost': itemJson['item']['shareable_item_information']
                    ['unit_cost'],
                'encrypted_id': itemJson['item']['shareable_item_information']
                    ['encrypted_id'],
                'qr_code_image_data': itemJson['item']
                    ['shareable_item_information']['qr_code_image_data'],
                'acquired_date': itemJson['item']['shareable_item_information']
                    ['acquired_date'],
              },
              'product_stock': {
                'product_name': {
                  'product_name_id': itemJson['item']['product_stock']
                      ['product_name']['product_name_id'],
                  'product_name': itemJson['item']['product_stock']
                      ['product_name']['product_name'],
                },
                'product_description': {
                  'product_description_id': itemJson['item']['product_stock']
                      ['product_description']['product_description_id'],
                  'product_description': itemJson['item']['product_stock']
                      ['product_description']['product_description'],
                },
              },
            }
          : {
              'equipment_id': itemJson['item']['equipment_id'],
              'shareable_item_information': {
                'base_item_id': itemJson['item']['shareable_item_information']
                    ['base_item_id'],
                'specification': itemJson['item']['shareable_item_information']
                    ['specification'],
                'unit': itemJson['item']['shareable_item_information']['unit'],
                'quantity': itemJson['item']['shareable_item_information']
                    ['quantity'],
                'unit_cost': itemJson['item']['shareable_item_information']
                    ['unit_cost'],
                'encrypted_id': itemJson['item']['shareable_item_information']
                    ['encrypted_id'],
                'qr_code_image_data': itemJson['item']
                    ['shareable_item_information']['qr_code_image_data'],
                'acquired_date': itemJson['item']['shareable_item_information']
                    ['acquired_date'],
              },
              'product_stock': {
                'product_name': {
                  'product_name_id': itemJson['item']['product_stock']
                      ['product_name']['product_name_id'],
                  'product_name': itemJson['item']['product_stock']
                      ['product_name']['product_name'],
                },
                'product_description': {
                  'product_description_id': itemJson['item']['product_stock']
                      ['product_description']['product_description_id'],
                  'product_description': itemJson['item']['product_stock']
                      ['product_description']['product_description'],
                },
              },
              'manufacturer_brand': {
                'manufacturer': {
                  'manufacturer_id': itemJson['item']['manufacturer_brand']
                      ['manufacturer']['manufacturer_id'],
                  'manufacturer_name': itemJson['item']['manufacturer_brand']
                      ['manufacturer']['manufacturer_name'],
                },
                'brand': {
                  'brand_id': itemJson['item']['manufacturer_brand']['brand']
                      ['brand_id'],
                  'brand_name': itemJson['item']['manufacturer_brand']['brand']
                      ['brand_name'],
                },
              },
              'model': {
                'model_id': itemJson['item']['model']['model_id'],
                'model_name': itemJson['item']['model']['model_name'],
              },
              'serial_no': itemJson['item']['serial_no'],
              'asset_classification': itemJson['item']['asset_classification'],
              'asset_sub_class': itemJson['item']['asset_sub_class'],
              'estimated_useful_life': itemJson['item']
                  ['estimated_useful_life'],
            };

      final issuanceItem = IssuanceItem.fromJson({
        'issuance_id': itemJson['issuance_id'],
        'item': itemData,
        'issued_quantity': itemJson['issued_quantity'],
      });

      return issuanceItem;
    }).toList();

    final requestedItems = (prJson['requested_items'] as List<dynamic>)
        .map((requestedItem) => RequestedItem.fromJson({
              'id': requestedItem['id'],
              'pr_id': requestedItem['pr_id'],
              'product_name_id': requestedItem['product_name']
                  ['product_name_id'],
              'product_name': requestedItem['product_name']['product_name'],
              'product_description_id': requestedItem['product_description']
                  ['product_description_id'],
              'product_description': requestedItem['product_description']
                  ['product_description'],
              'specification': requestedItem['specification'],
              'unit': requestedItem['unit'],
              'quantity': requestedItem['quantity'],
              'remaining_quantity': requestedItem['remaining_quantity'],
              'unit_cost': requestedItem['unit_cost'],
              'total_cost': requestedItem['total_cost'],
              'status': requestedItem['status'],
            }).toJson())
        .toList();

    final requestingOfficerJson = prJson['requesting_officer'];
    final requestingOfficerData = {
      'id': requestingOfficerJson['id'],
      'user_id': requestingOfficerJson['user_id'],
      'name': requestingOfficerJson['name'],
      'position_id': requestingOfficerJson['position_id'],
      'office_name': requestingOfficerJson['office_name'],
      'position_name': requestingOfficerJson['position_name'],
      'position_history':
          (requestingOfficerJson['position_history'] as List<dynamic>)
              .map((position) {
        print('position: $position');
        return PositionHistory.fromJson({
          'id': position['id'],
          'officer_id': position['officer_id'],
          'position_id': position['position_id'],
          'office_name': position['office_name'],
          'position_name': position['position_name'],
          'created_at': position['created_at'],
        }).toJson();
      }).toList(),
      'status': requestingOfficerJson['status'],
      'is_archived': requestingOfficerJson['is_archived'],
    };

    final approvingOfficerJson = prJson['approving_officer'];
    final approvingOfficerData = {
      'id': approvingOfficerJson['id'],
      'user_id': approvingOfficerJson['user_id'],
      'name': approvingOfficerJson['name'],
      'position_id': approvingOfficerJson['position_id'],
      'office_name': approvingOfficerJson['office_name'],
      'position_name': approvingOfficerJson['position_name'],
      'position_history':
          (approvingOfficerJson['position_history'] as List<dynamic>)
              .map((position) {
        return PositionHistory.fromJson({
          'id': position['id'],
          'officer_id': position['officer_id'],
          'position_id': position['position_id'],
          'office_name': position['office_name'],
          'position_name': position['position_name'],
          'created_at': position['created_at'],
        }).toJson();
      }).toList(),
      'status': approvingOfficerJson['status'],
      'is_archived': approvingOfficerJson['is_archived'],
    };

    final purchaseRequest = PurchaseRequest.fromJson({
      'id': prJson['id'],
      'entity_id': prJson['entity']['entity_id'],
      'entity_name': prJson['entity']['entity_name'],
      'fund_cluster': prJson['fund_cluster'],
      'office_id': prJson['office']['office_id'],
      'office_name': prJson['office']['office_name'],
      'responsibility_center_code': prJson['responsibility_center_code'],
      'date': prJson['date'],
      'requested_items': requestedItems,
      'purpose': prJson['purpose'],
      'requesting_officer': requestingOfficerData,
      'approving_officer': approvingOfficerData,
      'status': prJson['status'],
      'is_archived': prJson['is_archived'],
    });

    final receivingOfficer =
        Officer.fromJson(json['receiving_officer'] as Map<String, dynamic>);

    final sendingOfficer =
        Officer.fromJson(json['sending_officer'] as Map<String, dynamic>);

    final par = PropertyAcknowledgementReceipt(
      id: json['id'] as String,
      parId: json['par_id'] as String,
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

    print('converted par obj: ${par.toJson()}');
    return par;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'par_id': parId,
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

class RequisitionAndIssueSlip extends Issuance {
  const RequisitionAndIssueSlip({
    required super.id,
    required this.risId,
    required super.items,
    required super.purchaseRequest, // get the requesting officer here
    this.responsibilityCenterCode,
    this.purpose,
    required this.approvingOfficer,
    required this.issuingOfficer,
    required super.receivingOfficer,
    required super.issuedDate,
    super.returnDate,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  final String risId;
  final String? purpose; // can be extracted from PO if they want
  final String? responsibilityCenterCode;
  final Officer approvingOfficer;
  final Officer issuingOfficer;

  factory RequisitionAndIssueSlip.fromJson(Map<String, dynamic> json) {
    final prJson = json['purchase_request'];

    print('json received by ris: $json');
    print('items json received by ris: ${json['items']}');

    final items = (json['items'] as List<dynamic>).map((itemJson) {
      print('item json: $itemJson');
      final itemData = itemJson['item']['supply_id'] != null
          ? {
              'supply_id': itemJson['item']['supply_id'],
              'equipment_id': itemJson['item']['equipment_id'],
              'shareable_item_information': {
                'base_item_id': itemJson['item']['shareable_item_information']
                    ['base_item_id'],
                'specification': itemJson['item']['shareable_item_information']
                    ['specification'],
                'unit': itemJson['item']['shareable_item_information']['unit'],
                'quantity': itemJson['item']['shareable_item_information']
                    ['quantity'],
                'unit_cost': itemJson['item']['shareable_item_information']
                    ['unit_cost'],
                'encrypted_id': itemJson['item']['shareable_item_information']
                    ['encrypted_id'],
                'qr_code_image_data': itemJson['item']
                    ['shareable_item_information']['qr_code_image_data'],
                'acquired_date': itemJson['item']['shareable_item_information']
                    ['acquired_date'],
              },
              'product_stock': {
                'product_name': {
                  'product_name_id': itemJson['item']['product_stock']
                      ['product_name']['product_name_id'],
                  'product_name': itemJson['item']['product_stock']
                      ['product_name']['product_name'],
                },
                'product_description': {
                  'product_description_id': itemJson['item']['product_stock']
                      ['product_description']['product_description_id'],
                  'product_description': itemJson['item']['product_stock']
                      ['product_description']['product_description'],
                },
              },
            }
          : {
              'equipment_id': itemJson['item']['equipment_id'],
              'shareable_item_information': {
                'base_item_id': itemJson['item']['shareable_item_information']
                    ['base_item_id'],
                'specification': itemJson['item']['shareable_item_information']
                    ['specification'],
                'unit': itemJson['item']['shareable_item_information']['unit'],
                'quantity': itemJson['item']['shareable_item_information']
                    ['quantity'],
                'unit_cost': itemJson['item']['shareable_item_information']
                    ['unit_cost'],
                'encrypted_id': itemJson['item']['shareable_item_information']
                    ['encrypted_id'],
                'qr_code_image_data': itemJson['item']
                    ['shareable_item_information']['qr_code_image_data'],
                'acquired_date': itemJson['item']['shareable_item_information']
                    ['acquired_date'],
              },
              'product_stock': {
                'product_name': {
                  'product_name_id': itemJson['item']['product_stock']
                      ['product_name']['product_name_id'],
                  'product_name': itemJson['item']['product_stock']
                      ['product_name']['product_name'],
                },
                'product_description': {
                  'product_description_id': itemJson['item']['product_stock']
                      ['product_description']['product_description_id'],
                  'product_description': itemJson['item']['product_stock']
                      ['product_description']['product_description'],
                },
              },
              'manufacturer_brand': {
                'manufacturer': {
                  'manufacturer_id': itemJson['item']['manufacturer_brand']
                      ['manufacturer']['manufacturer_id'],
                  'manufacturer_name': itemJson['item']['manufacturer_brand']
                      ['manufacturer']['manufacturer_name'],
                },
                'brand': {
                  'brand_id': itemJson['item']['manufacturer_brand']['brand']
                      ['brand_id'],
                  'brand_name': itemJson['item']['manufacturer_brand']['brand']
                      ['brand_name'],
                },
              },
              'model': {
                'model_id': itemJson['item']['model']['model_id'],
                'model_name': itemJson['item']['model']['model_name'],
              },
              'serial_no': itemJson['item']['serial_no'],
              'asset_classification': itemJson['item']['asset_classification'],
              'asset_sub_class': itemJson['item']['asset_sub_class'],
              'estimated_useful_life': itemJson['item']
                  ['estimated_useful_life'],
            };

      final issuanceItem = IssuanceItem.fromJson({
        'issuance_id': itemJson['issuance_id'],
        'item': itemData,
        'issued_quantity': itemJson['issued_quantity'],
      });

      return issuanceItem;
    }).toList();

    final requestedItems = (prJson['requested_items'] as List<dynamic>)
        .map((requestedItem) => RequestedItem.fromJson({
              'id': requestedItem['id'],
              'pr_id': requestedItem['pr_id'],
              'product_name_id': requestedItem['product_name']
                  ['product_name_id'],
              'product_name': requestedItem['product_name']['product_name'],
              'product_description_id': requestedItem['product_description']
                  ['product_description_id'],
              'product_description': requestedItem['product_description']
                  ['product_description'],
              'specification': requestedItem['specification'],
              'unit': requestedItem['unit'],
              'quantity': requestedItem['quantity'],
              'remaining_quantity': requestedItem['remaining_quantity'],
              'unit_cost': requestedItem['unit_cost'],
              'total_cost': requestedItem['total_cost'],
              'status': requestedItem['status'],
            }).toJson())
        .toList();

    final requestingOfficerJson = prJson['requesting_officer'];
    final requestingOfficerData = {
      'id': requestingOfficerJson['id'],
      'user_id': requestingOfficerJson['user_id'],
      'name': requestingOfficerJson['name'],
      'position_id': requestingOfficerJson['position_id'],
      'office_name': requestingOfficerJson['office_name'],
      'position_name': requestingOfficerJson['position_name'],
      'position_history':
          (requestingOfficerJson['position_history'] as List<dynamic>)
              .map((position) {
        print('position: $position');
        return PositionHistory.fromJson({
          'id': position['id'],
          'officer_id': position['officer_id'],
          'position_id': position['position_id'],
          'office_name': position['office_name'],
          'position_name': position['position_name'],
          'created_at': position['created_at'],
        }).toJson();
      }).toList(),
      'status': requestingOfficerJson['status'],
      'is_archived': requestingOfficerJson['is_archived'],
    };

    final approvingOfficerJson = prJson['approving_officer'];
    final approvingOfficerData = {
      'id': approvingOfficerJson['id'],
      'user_id': approvingOfficerJson['user_id'],
      'name': approvingOfficerJson['name'],
      'position_id': approvingOfficerJson['position_id'],
      'office_name': approvingOfficerJson['office_name'],
      'position_name': approvingOfficerJson['position_name'],
      'position_history':
          (approvingOfficerJson['position_history'] as List<dynamic>)
              .map((position) {
        return PositionHistory.fromJson({
          'id': position['id'],
          'officer_id': position['officer_id'],
          'position_id': position['position_id'],
          'office_name': position['office_name'],
          'position_name': position['position_name'],
          'created_at': position['created_at'],
        }).toJson();
      }).toList(),
      'status': approvingOfficerJson['status'],
      'is_archived': approvingOfficerJson['is_archived'],
    };

    final purchaseRequest = PurchaseRequest.fromJson({
      'id': prJson['id'],
      'entity_id': prJson['entity']['entity_id'],
      'entity_name': prJson['entity']['entity_name'],
      'fund_cluster': prJson['fund_cluster'],
      'office_id': prJson['office']['office_id'],
      'office_name': prJson['office']['office_name'],
      'responsibility_center_code': prJson['responsibility_center_code'],
      'date': prJson['date'],
      'requested_items': requestedItems,
      'purpose': prJson['purpose'],
      'requesting_officer': requestingOfficerData,
      'approving_officer': approvingOfficerData,
      'status': prJson['status'],
      'is_archived': prJson['is_archived'],
    });

    final approvingOfficer =
        Officer.fromJson(json['approving_officer'] as Map<String, dynamic>);

    final receivingOfficer =
        Officer.fromJson(json['receiving_officer'] as Map<String, dynamic>);

    final issuingOfficer =
        Officer.fromJson(json['issuing_officer'] as Map<String, dynamic>);

    return RequisitionAndIssueSlip(
      id: json['id'] as String,
      risId: json['ris_id'] as String,
      items: items,
      purchaseRequest: purchaseRequest,
      responsibilityCenterCode: json['responsibility_center_code'] as String?,
      purpose: json['purpose'] as String?,
      approvingOfficer: approvingOfficer,
      issuingOfficer: issuingOfficer,
      receivingOfficer: receivingOfficer,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] is String
          ? DateTime.parse(json['return_date'] as String)
          : json['issued_date'] as DateTime,
      qrCodeImageData: json['qr_code_image_data'] as String,
      isReceived: json['is_received'] as bool,
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ris_id': risId,
      'items': items.map((item) => item.toJson()).toList(),
      'purchase_request': purchaseRequest.toJson(),
      'responsibility_center_code': responsibilityCenterCode,
      'purpose': purpose,
      'approving_officer': approvingOfficer.toJson(),
      'issuing_officer': issuingOfficer.toJson(),
      'receiving_officer': receivingOfficer.toJson(),
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'qr_code_image_data': qrCodeImageData,
      'is_received': isReceived,
      'is_archived': isArchived,
    };
  }
}
