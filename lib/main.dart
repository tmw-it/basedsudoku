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
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Error handler to prevent app crashes
void _errorHandler(FlutterErrorDetails details) {
  // Log the error
  print('ERROR: ${details.exception}');
  print('STACK TRACE: ${details.stack}');
  
  // Only rethrow in debug mode
  if (kDebugMode) {
    FlutterError.dumpErrorToConsole(details);
  }
}

void main() {
  // Set up error handling
  FlutterError.onError = _errorHandler;
  
  // Catch errors not caught by Flutter
  runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
  }, (error, stack) {
    print('UNHANDLED ERROR: $error');
    print('STACK TRACE: $stack');
  });
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
    // Start puzzle generation in background with reduced initial load
    Future.microtask(() async {
      // Generate fewer puzzles initially
      await PuzzleGenerator.preGenerateMasterPuzzles(count: 2);
      // Add delay before generating evil puzzles
      await Future.delayed(const Duration(milliseconds: 500));
      await PuzzleGenerator.preGenerateEvilPuzzles(count: 2);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _newGame(Difficulty difficulty, {bool forceNew = false}) async {
    Navigator.of(_navigatorKey.currentContext!, rootNavigator: true)
        .popUntil((route) => route is PageRoute);

    SudokuGame? game;
    final prefs = await SharedPreferences.getInstance();
    final rawSaved = prefs.getString('based_sudoku_saved_game');
    print('[DEBUG] (START) Raw saved game in SharedPreferences: $rawSaved');
    bool loadedFromSave = false;
    
    // Only load saved game if not forcing a new game and the difficulties match
    if (!forceNew) {
      final jsonStr = rawSaved;
      if (jsonStr != null) {
        print('[DEBUG] Found saved game in SharedPreferences: $jsonStr');
        try {
          final jsonMap = json.decode(jsonStr);
          print('[DEBUG] jsonMap: $jsonMap');
          final loadedGame = SudokuGame.fromJson(jsonMap);
          final loadedId = loadedGame?.id;
          print('[DEBUG] loadedGame ID: $loadedId');
          print('[DEBUG] loadedGame: $loadedGame');
          print('[DEBUG] loadedGame.isCompleted: ${loadedGame?.isCompleted} (type: ${loadedGame?.isCompleted.runtimeType})');
          print('[DEBUG] loadedGame.difficulty: ${loadedGame?.difficulty}');
          
          if (loadedGame != null) {
            // Only restore if the difficulties match and the game isn't completed
            if (!loadedGame.isCompleted && loadedGame.difficulty == difficulty) {
              print('[DEBUG] Restoring saved game with matching difficulty: ${loadedGame.difficulty}');
              game = loadedGame;
              loadedFromSave = true;
            } else {
              print('[DEBUG] Saved game has different difficulty or is completed. Removing.');
              await prefs.remove('based_sudoku_saved_game');
            }
          } else {
            print('[DEBUG] Saved game is invalid. Removing.');
            await prefs.remove('based_sudoku_saved_game');
          }
        } catch (e) {
          print('[DEBUG] Error decoding saved game: $e');
          await prefs.remove('based_sudoku_saved_game');
        }
      } else {
        print('[DEBUG] No saved game found in SharedPreferences');
      }
    } else {
      // If forcing new, remove any saved game
      print('[DEBUG] Forcing new game, clearing saved game');
      await prefs.remove('based_sudoku_saved_game');
    }
    
    // Generate a new game if we didn't load a saved one
    if (game == null) {
      print('[DEBUG] Generating new puzzle for difficulty: ${difficulty.name}');
      game = PuzzleGenerator.generateGame(difficulty);
    }
    
    _games[difficulty] = game;

    print('[DEBUG] Pushing GameScreen with game ID: ${game.id}, loadedFromSave: $loadedFromSave');
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => game!,
          child: GameScreen(
            difficulty: difficulty,
            onNewGame: (d, {bool forceNew = false}) => _newGame(d, forceNew: forceNew),
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
                  onStartGame: (d, {bool forceNew = false}) => _newGame(d, forceNew: forceNew),
          ),
        ),
      ),
    );
  }
}
