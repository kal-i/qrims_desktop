String formatPosition(String position) {
  if (position.isEmpty) return '';

  // Split the position into words and extract the first letter of each word
  return position
      .split(' ') // Split into words
      .where((word) => word.isNotEmpty) // Filter out empty words
      .map((word) => word[0].toUpperCase()) // Extract and capitalize the first letter
      .join(); // Join the letters together
}