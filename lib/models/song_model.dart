class Song {
  final int? id;
  final String title;
  final List<int> notes;
  final int difficulty;

  Song({
    this.id,
    required this.title,
    required this.notes,
    this.difficulty = 1,
  });

  // Konvertiert Map aus DB zu Song-Objekt
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      notes: (map['notes'] as String).split(',').map(int.parse).toList(),
      difficulty: map['difficulty'] ?? 1,
    );
  }
}
