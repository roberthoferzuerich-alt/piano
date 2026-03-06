import 'package:flutter/material.dart';

class GameSettingsProvider extends ChangeNotifier {
  double _ballSpeed = 3.0;
  double _volume = 1.0;
  bool _isPaused = false;
  Color _themeColor = Colors.cyanAccent;

  // 1. Die neue Variable für die Beschriftung
  bool _showNoteLabels = true;

  double get ballSpeed => _ballSpeed;
  double get volume => _volume;
  bool get isPaused => _isPaused;
  Color get themeColor => _themeColor;

  // 2. Der fehlende Getter für das UI
  bool get showNoteLabels => _showNoteLabels;

  // ... deine anderen Methoden (setBallSpeed, etc.) ...

  // 3. Die fehlende Methode für den Switch
  void toggleNoteLabels() {
    _showNoteLabels = !_showNoteLabels;
    notifyListeners(); // Wichtig, damit die Notenbeschriftung sofort erscheint/verschwindet
  }

  void setPaused(bool value) {
    _isPaused = value;
    notifyListeners();
  }

  void setVolume(double value) {
    // Wir stellen sicher, dass der Wert zwischen 0.0 und 1.0 bleibt
    _volume = value.clamp(0.0, 1.0);

    // WICHTIG: Informiert alle Widgets (und Audio-Player),
    // dass sich die Lautstärke geändert hat.
    notifyListeners();
  }

  // In deiner Klasse GameSettingsProvider

  void setBallSpeed(double value) {
    // Wir speichern den neuen Wert vom Slider (z.B. 1.0 bis 10.0)
    _ballSpeed = value;

    // Dieser Ruf ist das "Signalhorn": Er sagt der NoteEngine
    // und dem UI, dass sie sich mit dem neuen Wert aktualisieren sollen.
    notifyListeners();
  }
}
