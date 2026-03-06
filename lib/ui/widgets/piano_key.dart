import 'package:flutter/material.dart';

class PianoKey extends StatelessWidget {
  final bool isBlack;
  final bool isPressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const PianoKey({
    Key? key,
    required this.isBlack,
    required this.isPressed,
    required this.onTapDown,
    required this.onTapUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Wichtig: behavior auf opaque setzen, damit auch transparente Bereiche Klicks fangen
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapUp(),
      child: isBlack ? _buildBlackKey() : _buildWhiteKey(),
    );
  }

  Widget _buildWhiteKey() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: isPressed ? Colors.yellow.shade200 : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        boxShadow: [
          if (!isPressed)
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
        ],
      ),
    );
  }

  Widget _buildBlackKey() {
    return Container(
      width: 35, // Feste Breite für schwarze Tasten
      height: 120,
      decoration: BoxDecoration(
        color: isPressed ? Colors.yellow.shade700 : Colors.black,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
        boxShadow: [
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }
}
