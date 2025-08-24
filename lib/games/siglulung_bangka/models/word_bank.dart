class WordBank {
  static List<String> getWords() {
    return [
      'quick',
      'brown',
      'fox',
      'jumps',
      'over',
      'the',
      'lazy',
      'dog',
      'name',
      'sorry',
      'place',
      'really',
      'not',
      'much',
      'direction',
      'perfect',
      'subject',
      'agree',
      'are',
      'gullible',
      'trait',
      'scene',
      'first',
      'fall',
      'love',
      'in',
      'with',
      'how',
      'inspire',
      'them',
      'manipulate',
      'confident',
      'power',
      'there',
      'use',
      'new',
      'process',
      'yes',
      'standard',
      'step',
      'guide',
      'table',
      'none',
      'coffee',
      'pretend',
      'never',
      'mind',
      'get',
      'build',
      'small',
      'extreme',
      'thing',
      'hot',
      'frog',
      'water',
      'boil',
      'target',
      'event',
      'party',
      'poetry',
      'pencil',
      'business',
      'card',
      'time',
      'independent',
      'other',
      'reason',
      'normal'
    ];
  }

  static List<String> getRandomWords(int count) {
    final words = getWords();
    words.shuffle();
    return words.take(count).toList();
  }

  static String getRandomWord() {
    final words = getWords();
    words.shuffle();
    return words.first;
  }
}
