class GameScore {
  final int? id;
  final int score;
  final String date;

  GameScore({this.id, required this.score, required this.date});

  // Konvertierung in Map für SQLite
  Map<String, dynamic> toMap() {
    return {'id': id, 'score': score, 'date': date};
  }
}
