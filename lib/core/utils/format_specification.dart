String formatSpecification(String rawSpec, String separator) {
  // Split the raw string using the separator and join it with new lines
  return rawSpec.split(separator).map((s) => s.trim()).join('\n');
}