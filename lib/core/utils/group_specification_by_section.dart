List<String> groupSpecificationBySection(String rawSpec) {
  final lines = rawSpec
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  final grouped = <String>[];
  final buffer = StringBuffer();

  for (final line in lines) {
    // Start a new section if line contains ':' and buffer is not empty
    if (line.contains(':') && buffer.isNotEmpty) {
      grouped.add(buffer.toString().trim());
      buffer.clear();
    }

    if (buffer.isNotEmpty) buffer.write('\n');
    buffer.write(line);
  }

  if (buffer.isNotEmpty) {
    grouped.add(buffer.toString().trim());
  }

  return grouped;
}
