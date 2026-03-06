import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano/provider/game_settings_provider.dart';
import 'package:piano/ui/SettingsScreen.dart';
import 'package:piano/ui/about_me_screen.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import 'package:piano/ui/game_screen.dart';

class SongSelectionScreen extends StatefulWidget {
  const SongSelectionScreen({super.key});

  @override
  State<SongSelectionScreen> createState() => _SongSelectionScreenState();
}

class _SongSelectionScreenState extends State<SongSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _refreshSongs();
  }

  void _refreshSongs() {
    setState(() {
      _songsFuture = DatabaseHelper.instance.getSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Piano Songbook",
          style: TextStyle(color: Colors.white70),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Geht zurück zum MainMenu
          },
        ),
        //        title: const Text("Piano Songbook"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () {
              _refreshSongs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Liste aktualisiert"),
                  duration: Duration(milliseconds: 500),
                ),
              );
            },
          ),
          // Das Drei-Punkte-Menü (Overflow Menu)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') _showImportDialog(context);
              if (value == 'refresh') _refreshSongs();
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              }
              if (value == 'about_me') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutMeScreen(),
                  ),
                );
              }

              if (value == 'exit') {
                _showExitConfirmation(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Liste aktualisieren'),
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Songs importieren'),
                ),
              ),

              const PopupMenuItem(
                // NEU: Einstellungen
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Einstellungen'),
                ),
              ),

              const PopupMenuItem(
                // NEU: Einstellungen
                value: 'about_me',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Über mich'),
                ),
              ),
              const PopupMenuDivider(),

              const PopupMenuItem(
                value: 'exit',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.redAccent),
                  title: Text(
                    'Spiel verlassen',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Keine Songs vorhanden.\nGehe oben rechts auf Importieren.",
              ),
            );
          }

          final songs = snapshot.data!;

          // GridView zeigt Kacheln statt einer Liste
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            // CrossAxisCount auf 2 oder 3 stellen für das Tablet
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 Kacheln nebeneinander
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3, // Verhältnis Breite zu Höhe
            ),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return TweenAnimationBuilder<double>(
                // Jede Kachel startet mit einer leichten Verzögerung basierend auf ihrem Index
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      // Bewegt die Kachel von 50 Pixeln unterhalb an ihre Endposition
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                // Hier rufen wir dein bestehendes Kachel-Widget auf
                child: _buildSongTile(song),
              );
            },
          );
        },
      ),
    );
  }

  // Hilfs-Widget für die einzelne Kachel
  Widget _buildSongTile(Map<String, dynamic> song) {
    final int difficulty = song['difficulty'] ?? 1;

    return GestureDetector(
      onTap: () {
        // 1. Pause-Status im Provider zurücksetzen, falls er noch auf true steht
        Provider.of<GameSettingsProvider>(
          context,
          listen: false,
        ).setPaused(false);

        // 2. Noten parsen
        final songNotes = (song['notes'] as String)
            .split(',')
            .map(int.parse)
            .toList();

        // 3. Zum Spiel navigieren
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GameScreen(songNotes: songNotes, songTitle: song['title']),
          ),
        );
      },
      onLongPress: () =>
          _showDeleteConfirmation(song), // Löschen per langem Druck
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note, size: 40, color: Colors.cyanAccent),
              const SizedBox(height: 12),
              Text(
                song['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildDifficultyStars(difficulty),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < difficulty ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lied löschen?"),
        content: Text("Möchtest du '${song['title']}' wirklich entfernen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteSong(song['id']);
              Navigator.pop(context);
              _refreshSongs();
            },
            child: const Text("Löschen", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    urlController.text =
        "https://gist.githubusercontent.com/roberthoferzuerich-alt/6442bc3cf08f8c53ed47e827535dda26/raw/137202aea0cd9cad05d62daf6a93a54898e089bb/index.json";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Songs importieren"),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(labelText: "JSON URL"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.importSongFromUrl(
                urlController.text,
              );
              _refreshSongs();
            },
            child: const Text("Importieren"),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Beenden?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Möchtest du Piano Master wirklich schließen?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Dialog schließen
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // Beendet die App komplett (Android & iOS)
              SystemNavigator.pop();
            },
            child: const Text("Beenden", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
