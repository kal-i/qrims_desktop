import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Add hash functionality to String
extension HashStringExtension on String {

  /// return the SHA256 hash of this [String]
  String get hashValue {
    return sha256.convert(utf8.encode(this)).toString();
  }
}