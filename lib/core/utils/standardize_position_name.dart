String standardizePositionName(String position) {
  final regex = RegExp(r'\b[iIvVxX]+\b'); // Matches Roman numerals
  // First, lowercase everything, then split into words
  final words = position.toLowerCase().split(' ');

  final formattedWords = words.map((word) {
    if (regex.hasMatch(word)) {
      return word.toUpperCase(); // Make Roman numerals uppercase
    } else {
      return word[0].toUpperCase() +
          word.substring(1); // Capitalize first letter
    }
  }).toList();

  return formattedWords.join(' ');
}
