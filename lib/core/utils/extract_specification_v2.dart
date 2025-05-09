Map<String, List<String>> extractSpecificationV2(
    String rawSpec, String separator) {
  final Map<String, List<String>> specs = {};
  String? currentKey;

  for (final line in rawSpec.split('\n')) {
    final trimmed = line.trim();

    if (trimmed.isEmpty) continue;

    if (trimmed.contains(separator)) {
      final parts = trimmed.split(separator);
      currentKey = parts[0].trim();
      final value = parts.sublist(1).join(separator).trim();

      specs[currentKey] = value.isNotEmpty ? [value] : [];
    } else if (currentKey != null) {
      specs[currentKey]!.add(trimmed);
    }
  }

  return specs;
}
