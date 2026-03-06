import 'package:flutter/material.dart';
import '../../game/note_engine.dart';

class PianoWidget extends StatefulWidget {
  final GlobalKey<NoteEngineState> engineKey;
  final Function(int) onPlayNote;

  const PianoWidget({
    super.key,
    required this.engineKey,
    required this.onPlayNote,
  });

  @override
  State<PianoWidget> createState() => _PianoWidgetState();
}

class _PianoWidgetState extends State<PianoWidget> {
  final Map<int, bool> _activeKeys = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // 1. Weiße Tasten (Basis-Ebene)
          Row(
            children: List.generate(
              7,
              (index) => Expanded(child: _buildWhiteKey(index)),
            ),
          ),

          // 2. Schwarze Tasten (Darüber liegend)
          LayoutBuilder(
            builder: (context, constraints) {
              double keyWidth = constraints.maxWidth / 7;
              return Stack(
                children: [
                  _buildBlackKey(position: 1, leftOffset: keyWidth * 0.7),
                  _buildBlackKey(position: 2, leftOffset: keyWidth * 1.7),
                  // Lücke bei Position 3 (zwischen E und F gibt es keine schwarze Taste)
                  _buildBlackKey(position: 4, leftOffset: keyWidth * 3.7),
                  _buildBlackKey(position: 5, leftOffset: keyWidth * 4.7),
                  _buildBlackKey(position: 6, leftOffset: keyWidth * 5.7),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteKey(int index) {
    bool isPressed = _activeKeys[index] ?? false;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _activeKeys[index] = true);

        // WICHTIG: Wir übergeben den INDEX (0-6), damit note_0.wav etc. gespielt wird
        widget.onPlayNote(index);

        // Trefferkontrolle für die fallenden Bälle
        widget.engineKey.currentState?.checkHit(index, 0.8, 1.0);
      },
      onTapUp: (_) => setState(() => _activeKeys[index] = false),
      onTapCancel: () => setState(() => _activeKeys[index] = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: isPressed ? Colors.cyanAccent.shade100 : Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlackKey({required int position, required double leftOffset}) {
    int blackKeyId = position + 100;
    bool isPressed = _activeKeys[blackKeyId] ?? false;

    return Positioned(
      left: leftOffset,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          setState(() => _activeKeys[blackKeyId] = true);

          // Für schwarze Tasten haben wir aktuell keine WAV-Sounds (note_0-6 sind nur weiß)
          // Wenn du Sounds für schwarz hast, müsstest du hier z.B. position + 10 übergeben

          widget.engineKey.currentState?.checkHit(blackKeyId, 0.8, 1.0);
        },
        onTapUp: (_) => setState(() => _activeKeys[blackKeyId] = false),
        onTapCancel: () => setState(() => _activeKeys[blackKeyId] = false),
        child: Container(
          width: 35, // Feste Breite für schwarze Tasten
          height: 120,
          decoration: BoxDecoration(
            color: isPressed ? Colors.cyanAccent.shade700 : Colors.black,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
