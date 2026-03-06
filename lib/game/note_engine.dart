import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import 'package:piano/provider/game_settings_provider.dart';
import 'package:piano/models/spark_painter_model.dart';

class NoteEngine extends StatefulWidget {
  final Function(int points, int laneIndex) onNoteHit;
  final List<int> currentSongNotes;

  NoteEngine({
    Key? key,
    required this.onNoteHit,
    required this.currentSongNotes,
  }) : super(key: key);

  @override
  NoteEngineState createState() => NoteEngineState();
}

class NoteEngineState extends State<NoteEngine>
    with SingleTickerProviderStateMixin {
  List<Note> activeNotes = [];
  // AnimationController entfernt, da Ticker ausreicht
  late Ticker _ticker;
  Timer? _spawnTimer;
  int currentNoteIndex = 0;

  List<Spark> activeSparks = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _startUpdateLoop();
    _startSpawning();
  }

  void _startUpdateLoop() {
    _ticker = createTicker((elapsed) {
      final settings = Provider.of<GameSettingsProvider>(
        context,
        listen: false,
      );

      // Wenn das Spiel pausiert ist, machen wir einfach gar nichts
      if (settings.isPaused) return;

      // 1. Noten bewegen
      _updateNotes();

      // 2. Funken bewegen (nur wenn welche da sind)
      if (activeSparks.isNotEmpty) {
        _updateParticles();
      }
    });
    _ticker.start();
  }

  void _updateNotes() {
    if (!mounted) return;
    final settings = Provider.of<GameSettingsProvider>(context, listen: false);

    setState(() {
      // Konstante Geschwindigkeit basierend auf den Einstellungen
      double currentFrameSpeed = 0.002 * settings.ballSpeed;
      for (var note in activeNotes) {
        note.yPosition += currentFrameSpeed;
      }
      // Entferne Noten, die unten aus dem Bild sind
      activeNotes.removeWhere((note) => note.yPosition > 1.0);
    });
  }

  void _updateParticles() {
    setState(() {
      activeSparks.removeWhere((spark) => !spark.update());
    });
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    // Intervall alle 100ms prüfen, ob eine neue Note fällig ist
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final settings = Provider.of<GameSettingsProvider>(
        context,
        listen: false,
      );

      // Nur spawnen, wenn nicht pausiert
      if (!settings.isPaused && mounted) {
        // Hier könntest du eine komplexere Logik einbauen,
        // aktuell spawnen wir einfach alle X Ticks
        if (random.nextInt(10) > 7) {
          // Beispiel für zufälliges Spawning
          _spawnNote();
        }
      }
    });
  }

  void _spawnNote() {
    if (widget.currentSongNotes.isEmpty) return;

    setState(() {
      int lane = widget
          .currentSongNotes[currentNoteIndex % widget.currentSongNotes.length];
      activeNotes.add(
        Note(laneIndex: lane, yPosition: -0.1, color: _getNeonColor(lane)),
      );
      currentNoteIndex++;
    });
  }

  // --- HIER SIND DIE WICHTIGEN METHODEN ---

  Color _getNeonColor(int lane) {
    const colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
    ];
    return colors[lane % colors.length];
  }

  void triggerNoteHitExplosion(Offset position, Color noteColor) {
    setState(() {
      // Erstelle 20 Funken pro Explosion
      for (int i = 0; i < 20; i++) {
        // Zufällige Flugrichtung (Winkel) und Geschwindigkeit
        double angle = random.nextDouble() * 2 * pi;
        double speed = random.nextDouble() * 4 + 2;
        Offset velocity = Offset(cos(angle) * speed, sin(angle) * speed);

        activeSparks.add(
          Spark(position: position, velocity: velocity, color: noteColor),
        );
      }
    });
  }

  // 1. Ändere int zu double für die Zonen
  void checkHit(int laneIndex, double hitZoneMin, double hitZoneMax) {
    // Wir suchen die Note manuell. Wenn keine gefunden wird, bleibt hitNote null.
    Note? hitNote;

    for (var note in activeNotes) {
      if (note.laneIndex == laneIndex &&
          note.yPosition >= hitZoneMin &&
          note.yPosition <= hitZoneMax) {
        hitNote = note;
        break; // Wir haben die passende Note gefunden, Schleife abbrechen
      }
    }

    // NUR wenn wir wirklich eine Note gefunden haben, führen wir den Rest aus
    if (hitNote != null) {
      final size = MediaQuery.of(context).size;
      double laneWidth = size.width / 7;
      double xPos = (hitNote.laneIndex * laneWidth) + (laneWidth / 2);
      double yPos = hitNote.yPosition * size.height;

      // Funken sprühen!
      triggerNoteHitExplosion(Offset(xPos, yPos), hitNote.color);

      setState(() {
        activeNotes.remove(hitNote);
      });

      widget.onNoteHit(10, laneIndex);
    } else {
      // Optional: Hier könntest du Code für ein "Miss" (Daneben getippt) einfügen
      print("Keine Note in Lane $laneIndex im Treffbereich gefunden.");
    }
  }

  // ---------------------------------------

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<GameSettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double laneWidth = constraints.maxWidth / 7;

        return Stack(
          children: [
            // 1. Spielfeld (Noten, Linien) - wie bisher
            _buildGameField(constraints, laneWidth),

            // 2. NEU: Partikel-Ebene (Ganz oben)
            IgnorePointer(
              // Wichtig: Damit die Funken keine Klicks abfangen
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: ParticlePainter(sparks: activeSparks),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton.small(
                backgroundColor: Colors.black45,
                shape: CircleBorder(
                  side: BorderSide(color: settings.themeColor, width: 1),
                ),
                child: Icon(Icons.refresh, color: settings.themeColor),
                onPressed: () =>
                    resetGame(), // Ruft die Methode direkt hier auf
              ),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      activeNotes.clear();
      activeSparks.clear();
      currentNoteIndex = 0;
    });
  }

  Widget _buildGameField(BoxConstraints constraints, double laneWidth) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Hintergrund-Linien
        Row(
          children: List.generate(
            7,
            (index) => Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white10, width: 1),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Die fallenden Bälle
        ...activeNotes.map((note) {
          return Positioned(
            top: note.yPosition * constraints.maxHeight,
            left: note.laneIndex * laneWidth,
            width: laneWidth,
            child: Center(
              child: Container(
                width: laneWidth * 0.6,
                height: laneWidth * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.white, note.color]),
                  boxShadow: [
                    BoxShadow(
                      color: note.color.withOpacity(0.6),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _spawnTimer?.cancel();
    super.dispose();
  }
}
