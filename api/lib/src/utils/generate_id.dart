import 'dart:math';

String generatedId(String baseId, {int length = 6}) {
  final random = Random();
  const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String randomString(int len) {
    return List.generate(len, (index) => characters[random.nextInt(characters.length)]).join();
  }

  return '$baseId${randomString(length)}';
}