String capitalizeWord(String word) {
  if (word.isEmpty) {
    return word;
  }

  return word.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return '';
  }).join(' ');
}
