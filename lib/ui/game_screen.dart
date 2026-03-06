// ui/game_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Audioplayers statt MIDI
import '../game/note_engine.dart';
import 'widgets/piano_widget.dart';

class GameScreen extends StatefulWidget {
  final List<int> songNotes;
  final String songTitle;

  const GameScreen({
    super.key,
    required this.songNotes,
    this.songTitle = "Piano Song",
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<NoteEngineState> _engineKey = GlobalKey<NoteEngineState>();

  // Audio-Setup: Eine Liste von Playern für die 7 Tasten
  final List<AudioPlayer> _audioPlayers = List.generate(
    7,
    (_) => AudioPlayer(),
  );
  int _currentScore = 0;

  @override
  void initState() {
    super.initState();
    _preloadSounds();
  }

  // Sounds vorladen für verzögerungsfreies Spielen
  void _preloadSounds() {
    for (int i = 0; i < 7; i++) {
      _audioPlayers[i].setSource(AssetSource('sounds/note_$i.wav'));
    }
  }

  // Funktion zum Abspielen eines Tons
  void _playNote(int index) async {
    if (index >= 0 && index < 7) {
      // 1. Lautstärke explizit auf Maximum setzen
      await _audioPlayers[index].setVolume(1.0);

      // 2. Nur zum Anfang springen, statt komplett zu stoppen
      await _audioPlayers[index].seek(Duration.zero);

      // 3. Abspielen
      _audioPlayers[index].resume();
    }
  }

  // Callback für Treffer in der NoteEngine (wenn ein Ball die Linie berührt)
  void _handleNoteHit(int points, int laneIndex) {
    setState(() {
      _currentScore += points;
    });

    // Sound abspielen, wenn der Ball getroffen wurde
    _playNote(laneIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // 1. Header Bereich
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.songTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Score: $_currentScore",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.music_note, color: Colors.cyanAccent),
                ],
              ),
            ),
          ),

          // 2. Spielfeld (NoteEngine)
          Expanded(
            child: NoteEngine(
              key: _engineKey,
              onNoteHit: _handleNoteHit,
              currentSongNotes: widget.songNotes,
            ),
          ),

          // 3. Klavier-Eingabe
          PianoWidget(
            engineKey: _engineKey,
            onPlayNote: (index) => _playNote(index), // Übergabe an das Widget
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }
}
