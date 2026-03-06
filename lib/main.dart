import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano/provider/game_settings_provider.dart';
import 'package:piano/ui/song_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  // 1. Flutter Engine initialisieren
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();

  // 2. Querformat erzwingen
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 3. App mit dem Provider starten
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameSettingsProvider()),
        // Hier könntest du später weitere Provider hinzufügen (z.B. UserProvider)
      ],
      child: const PianoAcademyApp(),
    ),
  );
}

class PianoAcademyApp extends StatelessWidget {
  const PianoAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Piano Academy Clone',
      debugShowCheckedModeBanner: false,

      // Dunkles Theme für den modernen Game-Look
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Sehr dunkles Grau
        useMaterial3: true,
      ),

      // Der Startbildschirm der App
      home: const SongSelectionScreen(),
    );
  }
}
