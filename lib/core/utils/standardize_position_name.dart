String standardizePositionName(String position) {
  final regex = RegExp(r'(\b[IiVvXx]+\b)'); // Matches Roman numerals
  return position.replaceAllMapped(regex, (match) {
    return match.group(0)!.toUpperCase(); // Convert to uppercase
  });
}
