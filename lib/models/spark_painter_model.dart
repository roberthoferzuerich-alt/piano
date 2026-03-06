import 'dart:math';
import 'package:flutter/material.dart';

// Diagramm 1: DIE DATA (Ein einzelner Funke)
class Spark {
  Offset position;
  Offset velocity; // Geschwindigkeit (X und Y)
  double life; // 1.0 (neu) bis 0.0 (tot)
  Color color;

  Spark({
    required this.position,
    required this.velocity,
    required this.color,
    this.life = 1.0,
  });

  // Diagramm 3: DIE ENGINE (Wird 60 Mal pro Sekunde aufgerufen)
  bool update() {
    position += velocity; // Bewegung anwenden
    velocity = Offset(
      velocity.dx * 0.95,
      velocity.dy * 0.95 + 0.1,
    ); // Reibung + Schwerkraft
    life -= 0.03; // Lebenszeit verringern
    return life > 0; // Lebt der Funke noch?
  }
}

// Diagramm 4: DIE RENDER (Zeichnet alle aktiven Funken)
class ParticlePainter extends CustomPainter {
  final List<Spark> sparks;
  final Random random = Random();

  ParticlePainter({required this.sparks});

  @override
  void paint(Canvas canvas, Size size) {
    for (var spark in sparks) {
      // Glow-Effekt (Neon) durch zwei Kreise
      // 1. Äußerer, transparenter Glow
      final outerPaint = Paint()
        ..color = spark.color.withOpacity(spark.life * 0.3)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          5,
        ); // Der Glow-Effekt

      canvas.drawCircle(spark.position, 6 * spark.life, outerPaint);

      // 2. Innerer, heller Kern
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(spark.life)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(spark.position, 2 * spark.life, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Immer neu zeichnen
}
