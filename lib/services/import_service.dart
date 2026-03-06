import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/database_helper.dart';

class ImportService {
  static Future<bool> downloadAndSaveSongs(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        // Prüfen, ob es eine Liste von Liedern ist
        if (decodedData is List) {
          for (var item in decodedData) {
            await _saveToDatabase(item);
          }
        } else {
          // Es ist nur ein einzelnes Lied
          await _saveToDatabase(decodedData);
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Massen-Import-Fehler: $e");
      return false;
    }
  }

  // Hilfsmethode zum Speichern (DRY - Don't Repeat Yourself)
  static Future<void> _saveToDatabase(Map<String, dynamic> songData) async {
    final db = await DatabaseHelper.instance.database;

    // Prüfen, ob das Lied schon existiert
    List<Map> existing = await db.query(
      'songs',
      where: 'title = ?',
      whereArgs: [songData['title']],
    );

    if (existing.isEmpty) {
      String notesString = (songData['notes'] as List).join(',');
      await DatabaseHelper.instance.insertSong({
        'title': songData['title'],
        'notes': notesString,
        'difficulty': songData['difficulty'] ?? 1,
      });
    } else {
      print("Überspringe ${songData['title']}, bereits vorhanden.");
    }
  }
}
