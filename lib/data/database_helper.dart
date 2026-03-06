import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('piano_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        notes TEXT, -- Gespeichert als CSV, z.B. "0,1,2,0,0,1,2,0"
        difficulty INTEGER
      )
    ''');
  }

  Future<void> importSongFromUrl(String url, {String? fallbackTitle}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          for (var item in data) {
            // Prüfen, ob es ein Verweis (Index) auf eine andere JSON-Datei ist
            if (item is Map &&
                item.containsKey('url') &&
                !item.containsKey('notes')) {
              await importSongFromUrl(
                item['url'],
                fallbackTitle: item['name'] ?? item['title'],
              );
            } else if (item is Map) {
              // Es ist direkt ein Song-Objekt
              await _insertSongIntoDb(Map<String, dynamic>.from(item));
            }
          }
        } else if (data is Map) {
          // Einzelnes Objekt (Song oder Verweis)
          if (data.containsKey('url') && !data.containsKey('notes')) {
            await importSongFromUrl(
              data['url'],
              fallbackTitle: data['name'] ?? data['title'],
            );
          } else {
            var songMap = Map<String, dynamic>.from(data);
            // Fallback-Titel setzen, falls im JSON keiner vorhanden ist
            if (fallbackTitle != null &&
                songMap['title'] == null &&
                songMap['name'] == null) {
              songMap['title'] = fallbackTitle;
            }
            await _insertSongIntoDb(songMap);
          }
        }
      }
    } catch (e) {
      print("Fehler beim Import von $url: $e");
    }
  }

  Future<void> _insertSongIntoDb(Map<String, dynamic> songData) async {
    // 1. Titel ermitteln (Fallback auf 'name', falls 'title' fehlt)
    String? title = songData['title'] ?? songData['name'];

    // Validierung: Verhindert Abstürze bei unvollständigen Daten
    if (title == null || songData['notes'] == null) {
      print("Import übersprungen: Fehlender Titel oder Noten in $songData");
      return;
    }

    final db = await database;

    // Vermeide Dubletten anhand des Titels
    List<Map> existing = await db.query(
      'songs',
      where: 'title = ?',
      whereArgs: [title],
    );

    if (existing.isEmpty) {
      // Robustere Verarbeitung: Akzeptiert Noten als Liste oder String
      String notesString;
      if (songData['notes'] is List) {
        notesString = (songData['notes'] as List).join(',');
      } else {
        notesString = songData['notes'].toString();
      }

      await db.insert('songs', {
        'title': title,
        'notes': notesString,
        'difficulty': songData['difficulty'] ?? 1,
      });
    }
  }

  // Diese Methode hat gefehlt:
  Future<int> insertSong(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('songs', row);
  }

  Future<int> deleteSong(int id) async {
    Database db = await instance.database;
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSongs() async {
    Database db = await instance.database;
    // Wir sortieren nach ID absteigend, damit neue Imports oben stehen
    return await db.query('songs', orderBy: 'id DESC');
  }

  Future<int> insertScore(int score) async {
    final db = await instance.database;
    return await db.insert('scores', {
      'score': score,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getHighScores() async {
    final db = await instance.database;
    return await db.query('scores', orderBy: 'score DESC', limit: 5);
  }
}
