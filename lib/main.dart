
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LyamApp());
}

class LyamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyam Interactive App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LyamHomePage(),
    );
  }
}

class LyamHomePage extends StatefulWidget {
  @override
  _LyamHomePageState createState() => _LyamHomePageState();
}

class _LyamHomePageState extends State<LyamHomePage> {
  String emotion = "neutral";
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastCommand = "";
  late FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _lastCommand = result.recognizedWords;
            _executeCommand(_lastCommand);
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _executeCommand(String command) {
    if (command.contains("heureux")) {
      setState(() => emotion = "happy");
      _tts.speak("Je suis heureux!");
    } else if (command.contains("triste")) {
      setState(() => emotion = "angry");
      _tts.speak("Je suis en colère!");
    } else {
      setState(() => emotion = "neutral");
      _tts.speak("Je ne comprends pas la commande.");
    }
  }

  Widget _buildCharacter() {
    switch (emotion) {
      case "happy":
        return Lottie.asset('assets/happy_character.json', width: 200, height: 200);
      case "angry":
        return Lottie.asset('assets/angry_character.json', width: 200, height: 200);
      case "neutral":
      default:
        return Lottie.asset('assets/neutral_character.json', width: 200, height: 200);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lyam Assistant')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCharacter(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: Text(_isListening ? "Stop Listening" : "Start Listening"),
            ),
          ],
        ),
      ),
    );
  }
}
