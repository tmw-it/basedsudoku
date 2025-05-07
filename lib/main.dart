import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:based_sudoku/models/sudoku_game.dart';
import 'package:based_sudoku/models/settings_model.dart';
import 'package:based_sudoku/screens/game_screen.dart';
import 'package:based_sudoku/screens/landing_screen.dart';
import 'package:based_sudoku/utils/puzzle_generator.dart';
import 'package:based_sudoku/theme/nord_theme.dart';
import 'package:based_sudoku/theme/android_theme.dart';
import 'dart:io' show Platform;
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final Map<Difficulty, SudokuGame> _games = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Start puzzle generation in background
    Future.microtask(() async {
      await PuzzleGenerator.preGenerateMasterPuzzles(count: 5);
      await PuzzleGenerator.preGenerateEvilPuzzles(count: 5);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _newGame(Difficulty difficulty, {bool forceNew = false}) {
    // Close any open dialogs first
    Navigator.of(_navigatorKey.currentContext!, rootNavigator: true)
        .popUntil((route) => route is PageRoute);

    // Only generate a new game if forced or if no game exists
    if (forceNew || !_games.containsKey(difficulty)) {
      _games[difficulty] = PuzzleGenerator.generateGame(difficulty);
    }
    final game = _games[difficulty]!;

    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => game,
          child: GameScreen(
            difficulty: difficulty,
            onNewGame: (d) => _newGame(d, forceNew: true),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsModel()),
      ],
      child: Consumer<SettingsModel>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Based Sudoku',
          theme: Platform.isAndroid 
              ? (settings.isDarkMode ? AndroidTheme.dark : AndroidTheme.light)
              : (settings.isDarkMode ? NordTheme.dark : NordTheme.light),
          navigatorKey: _navigatorKey,
          home: _isLoading
              ? const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading puzzles...'),
                      ],
                    ),
                  ),
                )
              : LandingScreen(
                  onStartGame: _newGame,
                ),
        ),
      ),
    );
  }
}
