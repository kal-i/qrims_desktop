import 'dart:io';

import 'package:api/src/item/item.dart';
import 'package:api/src/item/item_repository.dart';
import 'package:api/src/notification/cubit/notification_cubit.dart';
import 'package:api/src/notification/model/notification.dart';
import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/user_repository.dart';
import 'package:api/src/utils/encryption_utils.dart';
import 'package:api/src/utils/qr_code_utils.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final itemRepository = ItemRepository(connection);
  final userRepository =
      UserRepository(connection); // to be use later to get admin
  final sessionRepository = SessionRepository(connection);
  final notificationRepository = NotificationRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _registerItem(
        context, itemRepository, sessionRepository,),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

//['unread' | 'read']

Future<Response> _registerItem(
  RequestContext context,
  ItemRepository itemRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final headers = await context.request.headers;
    final bearerToken = headers['Authorization']?.substring(7) as String;
    final json = await context.request.json() as Map<String, dynamic>;
    final stockId = json['stock_id'] as int? ?? null;
    final specification = json['specification'] as String;
    final brand = json['brand'] as String;
    final model = json['model'] as String;
    final serialNo = json['serial_no'] as String;
    final manufacturer = json['manufacturer'] as String;

    AssetClassification? assetClassification;
    AssetSubClass? assetSubClass;
    Unit? unit;

    try {
      // if not null, we'll iterate through each elem in the enums to check if
      // matches the query params
      assetClassification = json['asset_classification'] != null
          ? AssetClassification.values.firstWhere(
              (e) => e.toString().split('.').last == json['asset_classification'])
          : AssetClassification.unknown;

      assetSubClass = json['asset_sub_class'] != null
          ? AssetSubClass.values.firstWhere(
              (e) => e.toString().split('.').last == json['asset_sub_class'])
          : AssetSubClass.unknown;

      unit = json['unit'] != null ? Unit.values.firstWhere((e) => e.toString().split('.').last == json['unit']) : Unit.undetermined;
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'message': 'Invalid asset classification or sub class.',
        },
      );
    }

    final quantity = json['quantity'] as int;
    final unitCost = json['unit_cost'] as double;
    final estimatedUsefulLife = json['estimated_useful_life'] as int;
    final acquiredDate = json['acquired_date'] is String
        ? DateTime.parse(json['acquired_date'] as String)
        : json['acquired_date'] as DateTime;

    final productName = json['product_name'] as String?;
    final description = json['description'] as String?;

    // gotta fill the id fn cause it is auto-gen when a new item/stock is inserted in db
    // and since some fields also need this id, set to temp val fn

    Stock? stockObj;
    if (productName != null && description != null) {
      stockObj = Stock(
        id: 0,
        productName: productName,
        description: description,
      );
    }

    final itemObj = Item(
      id: 0, // temp val
      stockId: stockId,
      specification: specification,
      brand: brand,
      model: model,
      serialNo: serialNo,
      manufacturer: manufacturer,
      assetClassification: assetClassification,
      assetSubClass: assetSubClass,
      unit: unit,
      quantity: quantity,
      unitCost: unitCost,
      estimatedUsefulLife: estimatedUsefulLife,
      acquiredDate: acquiredDate,
      encryptedId: '', // temp val
      qrCodeImageData: '', // temp val
    );

    final itemWithStock = ItemWithStock(
      item: itemObj,
      stock: stockObj,
    );

    final id = await itemRepository.registerItem(itemWithStock: itemWithStock);
    print('generated id after reg: $id');
    final encryptedId = EncryptionUtils.encryptId(id.toString());
    print(encryptedId);
    final qrCodeImageData = await QrCodeUtils.generateQRCode(encryptedId);
    print(qrCodeImageData);

    await itemRepository.updateItemAfterInsert(
      id: id,
      encryptedId: encryptedId,
      qrCodeImageData: qrCodeImageData,
    );

    final updatedItem = await itemRepository.getItemByEncryptedId(
      encryptedId: encryptedId,
    );

    print('update item: $updatedItem');

    if (updatedItem != null) {
      final extractedUserId =
      await sessionRepository.extractUserIdFromSessionToken(
        token: bearerToken,
      );

      // await notificationCubit.sendNotification(
      //   recipientId: 1,
      //   senderId: extractedUserId!,
      //   message: 'Item registered.',
      //   type: NotificationType.itemRegistration,
      //   referenceId: id,
      // );

      return Response.json(
        statusCode: 200,
        body: {
          'item': updatedItem.toJson(),
        },
      );
    } else {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'message': 'Item not found after creation.',
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'message': e.toString().contains('Serial no. already exists.') ? 'Serial no. already exists.' : 'Error registering item(s).',
      }
    );
  }
}
