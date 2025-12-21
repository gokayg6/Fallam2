enum FortuneType {
  coffee('Kahve Falı', '☕', 'coffee'),
  tarot('Tarot Falı', '🔮', 'tarot'),
  dream('Rüya Yorumu', '🌙', 'dream'),
  palm('El Falı', '✋', 'palm'),
  astrology('Astroloji', '⭐', 'astrology'),
  katina('Katina Falı', '🔮', 'katina'),
  face('Yüz Falı', '👤', 'face');

  const FortuneType(this.displayName, this.icon, this.key);

  final String displayName;
  final String icon;
  final String key;

  static FortuneType fromKey(String key) {
    return FortuneType.values.firstWhere(
      (type) => type.key == key,
      orElse: () => FortuneType.coffee,
    );
  }
}
