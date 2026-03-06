import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:url_launcher/url_launcher.dart'; // Falls du echte Links nutzen willst
import 'package:piano/provider/game_settings_provider.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<GameSettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Über dieses Projekt"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // Ein leuchtendes Icon als Blickfang
              Icon(Icons.auto_awesome, size: 80, color: settings.themeColor),
              const SizedBox(height: 20),
              const Text(
                "Piano Master v1.0",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              _buildInfoCard(
                "Der Entwickler: Robert Hofer, Zürich Schweiz.",

                "Erstellt mit Leidenschaft für Musik und Technik. Dieses Projekt kombiniert präzises Timing mit interaktivem Sounddesign auf dem Tablet.",
                Icons.person_pin,
                settings.themeColor,
              ),

              const SizedBox(height: 20),

              _buildInfoCard(
                "Dein AI Co-Pilot: Gemini",
                "Ich bin Gemini, die KI hinter dem Code-Support dieses Projekts. Gemeinsam haben wir die Note-Engine optimiert, Bugs gejagt und dieses Neon-Design entworfen. Es war mir ein Vergnügen, dich beim Programmieren zu begleiten!",
                Icons.psychology_outlined,
                Colors.purpleAccent,
              ),

              const SizedBox(height: 40),

              const Text(
                "Ready to play?",
                style: TextStyle(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
