// List<String> extractSpecification(String rawSpec, String separator) {
//   // Split the raw string using the separator and trim each part
//   return rawSpec.split(separator).map((s) => s.trim()).toList();
// }

List<String> extractSpecification(String rawSpec, String separator) {
  final lines = rawSpec.split('\n');
  final List<String> result = [];

  for (final line in lines) {
    final trimmed = line.trimRight();

    if (trimmed.contains(separator)) {
      final parts = trimmed.split(separator);
      final key = parts[0].trim();
      final value = parts.sublist(1).join(separator).trim();

      // Preserve the key: value format
      if (value.isNotEmpty) {
        result.add('$key: $value');
      } else {
        result.add('$key:');
      }
    } else {
      result.add(trimmed);
    }
  }

  return result;
}
