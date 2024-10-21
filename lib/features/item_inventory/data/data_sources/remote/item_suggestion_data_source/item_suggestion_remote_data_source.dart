import 'package:flutter/cupertino.dart';

abstract interface class ItemSuggestionRemoteDataSource {
  Future<List<String>> getItemNames({
    String? productName,
  });

  Future<List<String>> getItemDescriptions({
    required String productName,
    String? productDescription,
  });
}
