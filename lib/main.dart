import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cool_sudoku/models/sudoku_game.dart';
import 'package:cool_sudoku/models/settings_model.dart';
import 'package:cool_sudoku/screens/game_screen.dart';
import 'package:cool_sudoku/screens/landing_screen.dart';
import 'package:cool_sudoku/utils/puzzle_generator.dart';
import 'package:cool_sudoku/theme/nord_theme.dart';
import 'package:cool_sudoku/theme/android_theme.dart';
import 'dart:io' show Platform;

void main() {
  // Pre-generate master and evil puzzles
  PuzzleGenerator.preGenerateMasterPuzzles();
  PuzzleGenerator.preGenerateEvilPuzzles();
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

  void _newGame(Difficulty difficulty, {bool forceNew = false}) {
    // Close any open dialogs first
    Navigator.of(_navigatorKey.currentContext!, rootNavigator: true)
        .popUntil((route) => route is PageRoute);

    // Only generate a new game if forced or if no game exists or the game is completed
    if (forceNew || !_games.containsKey(difficulty) || _games[difficulty]!.isCompleted) {
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
          title: 'Sudoku',
          theme: Platform.isAndroid 
              ? (settings.isDarkMode ? AndroidTheme.dark : AndroidTheme.light)
              : (settings.isDarkMode ? NordTheme.dark : NordTheme.light),
          navigatorKey: _navigatorKey,
          home: LandingScreen(
            onStartGame: _newGame,
          ),
        ),
      ),
    );
  }
}
