List<String> extractSpecification(String rawSpec, String separator) {
  // Split the raw string using the separator and trim each part
  return rawSpec.split(separator).map((s) => s.trim()).toList();
}
