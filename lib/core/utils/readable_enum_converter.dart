String readableEnumConverter(Object enumValue) {
  String enumName = enumValue.toString().split('.').last;

  String readableString = enumName
      .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), (Match match) => '${match[1]} ${match[2]}')
      .replaceAll('_', ' ')
      .replaceAllMapped(
          RegExp(r'\b\w'), (Match match) => match[0]!.toUpperCase());

  return readableString;
}
