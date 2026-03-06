import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piano/provider/game_settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Zugriff auf den Provider
    final settings = Provider.of<GameSettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Einstellungen",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle("Gameplay"),

          // Slider für Geschwindigkeit
          _buildSettingTile(
            title:
                "Fall-Geschwindigkeit: ${settings.ballSpeed.toStringAsFixed(1)}",
            icon: Icons.speed,
            child: Slider(
              value: settings.ballSpeed,
              min: 1.0,
              max: 10.0,
              activeColor: settings.themeColor,
              onChanged: (val) => settings.setBallSpeed(val),
            ),
          ),

          const Divider(color: Colors.white10),
          _buildSectionTitle("Audio"),

          // Slider für Lautstärke
          _buildSettingTile(
            title: "Lautstärke: ${(settings.volume * 100).toInt()}%",
            icon: Icons.volume_up,
            child: Slider(
              value: settings.volume,
              min: 0.0,
              max: 1.0,
              activeColor: settings.themeColor,
              onChanged: (val) => settings.setVolume(val),
            ),
          ),

          const Divider(color: Colors.white10),
          _buildSectionTitle("Anzeige"),

          // Switch für Noten-Beschriftung
          SwitchListTile(
            title: const Text(
              "Noten-Namen anzeigen",
              style: TextStyle(color: Colors.white),
            ),
            secondary: Icon(Icons.label, color: settings.themeColor),
            value: settings.showNoteLabels,
            activeColor: settings.themeColor,
            onChanged: (val) => settings.toggleNoteLabels(),
          ),
        ],
      ),
    );
  }

  // Hilfs-Widgets für ein sauberes Layout
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        child,
      ],
    );
  }
}
