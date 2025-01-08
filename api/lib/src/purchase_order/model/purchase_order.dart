import 'package:api/src/organization_management/models/officer.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';

class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }
}

// todo: add status []
class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.supplier,
    required this.date,
    required this.procurementMode,
    required this.gentleman,
    required this.deliveryPlace,
    required this.deliveryDate,
    required this.deliveryTerm,
    required this.paymentTerm,
    required this.description,
    required this.purchaseRequest,
    this.conformeOfficer,
    this.conformeDate,
    required this.superintendentOfficer,
    required this.fundsHolderOfficer,
    this.alobsNo,
  });

  final String id;
  final Supplier supplier;
  final DateTime date;
  final String procurementMode;
  final String gentleman;
  final String deliveryPlace;
  final DateTime deliveryDate;
  final int deliveryTerm;
  final int paymentTerm;
  final String description;
  final PurchaseRequest purchaseRequest;
  final Officer? conformeOfficer;
  final DateTime? conformeDate;
  final Officer superintendentOfficer;
  final Officer fundsHolderOfficer;
  final String? alobsNo;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final supplier =
        Supplier.fromJson(json['supplier'] as Map<String, dynamic>);
    final purchaseRequest = PurchaseRequest.fromJson(
        json['purchase_request'] as Map<String, dynamic>);
    final conformeOfficer = json['conforme_officer'] != null
        ? Officer.fromJson(json['conforme_officer'] as Map<String, dynamic>)
        : null;
    final superintendentOfficer = Officer.fromJson(
        json['superintendent_officer'] as Map<String, dynamic>);
    final fundsHolderOfficer =
        Officer.fromJson(json['funds_holder_officer'] as Map<String, dynamic>);

    return PurchaseOrder(
      id: json['id'] as String,
      supplier: supplier,
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : json['date'] as DateTime,
      procurementMode: json['procurement_mode'] as String,
      gentleman: json['gentleman'] as String,
      deliveryPlace: json['delivery_place'] as String,
      deliveryDate: json['delivery_date'] is String
          ? DateTime.parse(json['delivery_date'] as String)
          : json['delivery_date'] as DateTime,
      deliveryTerm: json['delivery_term'] as int,
      paymentTerm: json['payment_term'] as int,
      description: json['description'] as String,
      purchaseRequest: purchaseRequest,
      conformeOfficer: conformeOfficer,
      conformeDate: json['conforme_date'] is String
          ? DateTime.parse(json['conforme_date'] as String)
          : json['conforme_date'] as DateTime,
      superintendentOfficer: superintendentOfficer,
      fundsHolderOfficer: fundsHolderOfficer,
      alobsNo: json['alobs_no'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier': supplier.toJson(),
      'date': date.toIso8601String(),
      'procurement_mode': procurementMode,
      'gentleman': gentleman,
      'delivery_place': deliveryPlace,
      'delivery_date': deliveryDate,
      'delivery_term': deliveryTerm,
      'payment_term': paymentTerm,
      'description': description,
      'purchase_request': purchaseRequest.toJson(),
      'conforme_officer': conformeOfficer?.toJson(),
      'conforme_date': conformeDate?.toIso8601String(),
      'superintendent_officer': superintendentOfficer.toJson(),
      'funds_holder_officer': fundsHolderOfficer.toJson(),
      'alobs_no': alobsNo,
    };
  }
}
