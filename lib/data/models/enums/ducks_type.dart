enum DucksType {
  greetingDuck,
  greetingDuckStopped,
  explodingDuck,
  explodingDuckStopped,
  lovingDuck,
  lovingDuckStopped,
  cheersDuck,
  cheersDuckStopped,
  happyDuck,
  happyDuckStopped,
  sweetheartDuck,
  sweetheartDuckStopped;

  String get stoppedImage {
    switch (this) {
      case DucksType.greetingDuck:
        return 'greeting_duck_stopped';
      case DucksType.explodingDuck:
        return 'exploding_duck_stopped';
      case DucksType.lovingDuck:
        return 'loving_duck_stopped';
      case DucksType.cheersDuck:
        return 'cheers_duck_stopped';
      case DucksType.happyDuck:
        return 'happy_duck_stopped';
      case DucksType.sweetheartDuck:
        return 'sweetheart_duck_stopped';
      default:
        return '';
    }
  }

  String get name {
    switch (this) {
      case DucksType.greetingDuck:
        return 'greeting_duck';
      case DucksType.greetingDuckStopped:
        return 'greeting_duck_stopped';
      case DucksType.explodingDuck:
        return 'exploding_duck';
      case DucksType.explodingDuckStopped:
        return 'exploding_duck_stopped';
      case DucksType.lovingDuck:
        return 'loving_duck';
      case DucksType.lovingDuckStopped:
        return 'loving_duck_stopped';
      case DucksType.cheersDuck:
        return 'cheers_duck';
      case DucksType.cheersDuckStopped:
        return 'cheers_duck_stopped';
      case DucksType.happyDuck:
        return 'happy_duck';
      case DucksType.happyDuckStopped:
        return 'happy_duck_stopped';
      case DucksType.sweetheartDuck:
        return 'sweetheart_duck';
      case DucksType.sweetheartDuckStopped:
        return 'sweetheart_duck_stopped';
    }
  }
}
