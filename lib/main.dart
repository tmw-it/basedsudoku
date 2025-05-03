import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/models/sudoku_game.dart';
import 'package:sudoku/models/settings_model.dart';
import 'package:sudoku/screens/game_screen.dart';
import 'package:sudoku/screens/landing_screen.dart';
import 'package:sudoku/utils/puzzle_generator.dart';
import 'package:sudoku/theme/nord_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<Difficulty, SudokuGame> _games = {};
  final Map<Difficulty, Key> _gameKeys = {};
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    for (var d in Difficulty.values) {
      _games[d] = PuzzleGenerator.generateGame(d);
      _gameKeys[d] = UniqueKey();
    }
  }

  void _newGame(Difficulty difficulty) {
    setState(() {
      _games[difficulty] = PuzzleGenerator.generateGame(difficulty);
      _gameKeys[difficulty] = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the current game for the selected difficulty if needed
        ChangeNotifierProvider(create: (context) => SettingsModel()),
      ],
      child: Consumer<SettingsModel>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Sudoku',
          theme: settings.isDarkMode ? NordTheme.dark : NordTheme.light,
          navigatorKey: _navigatorKey,
          home: LandingScreen(
            onStartGame: (difficulty) {
              final game = _games[difficulty]!;
              final key = _gameKeys[difficulty]!;
              // If the puzzle is completed, generate a new one
              if (game.isCompleted) {
                setState(() {
                  _games[difficulty] = PuzzleGenerator.generateGame(difficulty);
                  _gameKeys[difficulty] = UniqueKey();
                });
              }
              final currentGame = _games[difficulty]!;
              final currentKey = _gameKeys[difficulty]!;
              _navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<SudokuGame>.value(
                    value: currentGame,
                    key: currentKey,
                    child: GameScreen(
                      key: currentKey,
                      difficulty: difficulty,
                      onNewGame: _newGame,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
