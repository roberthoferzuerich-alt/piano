import 'package:flutter/material.dart';

class Note {
  final int laneIndex; // 0 bis 6 für die weißen Tasten
  final Color color;
  double yPosition;    // 0.0 (oben) bis 1.0 (unten an der Ziellinie)

  Note({
    required this.laneIndex,
    required this.color,
    this.yPosition = 0.0,
  });
}