import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:based_sudoku/models/sudoku_game.dart';
import 'package:based_sudoku/widgets/number_pad.dart';
import 'package:based_sudoku/widgets/sudoku_board.dart';
import 'package:based_sudoku/widgets/timer_widget.dart';
import 'package:based_sudoku/theme/nord_theme.dart';
import 'dart:math';
import 'package:based_sudoku/screens/settings_page.dart';
import 'package:based_sudoku/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:based_sudoku/widgets/app_footer.dart';
import 'package:based_sudoku/screens/landing_screen.dart';
import 'package:based_sudoku/screens/about_page.dart';
import 'dart:convert';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final void Function(Difficulty, {bool forceNew}) onNewGame;

  const GameScreen({super.key, required this.difficulty, required this.onNewGame});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  bool isNoteMode = false;
  bool _shiftHeld = false;
  late FocusNode _focusNode;
  bool _congratsShown = false;
  Timer? _inactivityTimer;
  Timer? _saveDebounceTimer;
  static const String kSavedGameKey = 'based_sudoku_saved_game';
  late SudokuGame _game;
  DateTime? _lastInteractionTime;
  DateTime? _lastSaveTime;
  static const _saveDebounceDuration = Duration(seconds: 2);
  static const _minSaveInterval = Duration(seconds: 5);

  static const List<String> _genZCongrats = [
    "Sheesh! You just Sudoku'd that grid into oblivion!",
    "No cap, you're the main character of Sudoku.",
    "Big brain energy detected. Sudoku? More like Sudok-YOU!",
    "You just 100%-ed that puzzle. Certified legend.",
    "That was bussin'! Sudoku grid? More like Sudoku slayed.",
    "You ate and left no crumbs. Sudoku master!",
    "Vibe check: Passed. Sudoku check: Also passed.",
    "You're built different. Sudoku can't even.",
    "Sudoku: 0, You: 1. EZ clap.",
    "You just flexed on those numbers. Respect.",
    "That was lowkey impressive. Sudoku who?",
    "You understood the assignment. Sudoku complete.",
    "Not you speedrunning Sudoku like it's nothing.",
    "You just dropped a Sudoku W.",
    "Sudoku grid: 'I fear no man, but that player…'",
    "You're the CEO of Sudoku now.",
    "That was a Sudoku glow-up!",
    "You just made Sudoku your side quest.",
    "Sudoku? More like Sudok-done.",
    "You're on Sudoku X-Games mode!",
  ];

  void _setupInactivityTimer() {
    _inactivityTimer?.cancel();
    final settings = Provider.of<SettingsModel>(context, listen: false);
    _inactivityTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final now = DateTime.now();
        if (_lastInteractionTime != null && 
            now.difference(_lastInteractionTime!).inSeconds >= settings.pauseDelaySeconds) {
          _game.setPaused(true);
          timer.cancel();
        }
      },
    );
  }

  void _resetInactivityTimer() {
    _lastInteractionTime = DateTime.now();
    if (_inactivityTimer == null || !_inactivityTimer!.isActive) {
      _setupInactivityTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game = Provider.of<SudokuGame>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _game = Provider.of<SudokuGame>(context, listen: false);
    _setupInactivityTimer();
  }

  Future<void> _saveGame() async {
    // Cancel any pending save
    _saveDebounceTimer?.cancel();
    
    // Check if enough time has passed since last save
    final now = DateTime.now();
    if (_lastSaveTime != null && 
        now.difference(_lastSaveTime!) < _minSaveInterval) {
      return;
    }

    // Debounce the save operation
    _saveDebounceTimer = Timer(_saveDebounceDuration, () async {
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      if (!_game.isCompleted) {
        final jsonStr = json.encode(_game.toJson());
        await prefs.setString(kSavedGameKey, jsonStr);
        _lastSaveTime = DateTime.now();
      } else {
        await _clearSavedGame();
      }
    });
  }

  Future<void> _clearSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kSavedGameKey);
  }

  void _onGameChanged() {
    // Only save if the game state has actually changed
    if (!_game.isCompleted) {
      _saveGame();
    } else {
      _clearSavedGame();
    }
  }

  void _handleGameStateChanges(SudokuGame game) {
    // Handle game completion
    if (game.isCompleted && !_congratsShown && !game.isPaused) {
      // Clear saved game immediately when completed
      _clearSavedGame();
      
      Future.microtask(() {
        if (mounted && !_congratsShown && !game.isPaused) {
          _showCongratsDialog(context, game);
          setState(() => _congratsShown = true);
        }
      });
    } else if (!game.isCompleted && _congratsShown) {
      setState(() => _congratsShown = false);
    }

    // Handle pause state
    if (game.isPaused && ModalRoute.of(context)?.isCurrent == true) {
      Future.microtask(() {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          _showPauseDialog(context);
        }
      });
    }
  }

  void _showCongratsDialog(BuildContext context, SudokuGame game) async {
    // Update stats before showing dialog
    final prefs = await SharedPreferences.getInstance();
    final diff = game.difficulty;
    final gamesKey = 'stats_${diff.name}_games';
    final bestKey = 'stats_${diff.name}_best';
    final totalKey = 'stats_${diff.name}_total';
    int games = prefs.getInt(gamesKey) ?? 0;
    int? best = prefs.getInt(bestKey);
    int total = prefs.getInt(totalKey) ?? 0;
    int seconds = game.timeElapsed.inSeconds;
    games++;
    if (seconds > 0 && (best == null || seconds < best)) best = seconds;
    if (seconds > 0) total += seconds;
    await prefs.setInt(gamesKey, games);
    if (best != null) await prefs.setInt(bestKey, best);
    await prefs.setInt(totalKey, total);
    
    // Ensure saved game is cleared
    await _clearSavedGame();
    
    final random = Random();
    final phrase = _genZCongrats[random.nextInt(_genZCongrats.length)];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congrats!'),
        content: Text(phrase),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final selected = await showDialog<Difficulty>(
                context: context,
                builder: (context) {
                  Difficulty temp = game.difficulty;
                  return AlertDialog(
                    title: const Text('Select Difficulty'),
                    content: StatefulBuilder(
                      builder: (context, setState) => DropdownButton<Difficulty>(
                        value: temp,
                        onChanged: (d) => setState(() => temp = d!),
                        items: const [
                          DropdownMenuItem(value: Difficulty.easy, child: Text('Easy')),
                          DropdownMenuItem(value: Difficulty.medium, child: Text('Medium')),
                          DropdownMenuItem(value: Difficulty.hard, child: Text('Hard')),
                          DropdownMenuItem(value: Difficulty.master, child: Text('Master')),
                          DropdownMenuItem(value: Difficulty.evil, child: Text('Evil')),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(temp),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              if (selected != null) {
                setState(() {
                  isNoteMode = false;
                  _congratsShown = false;
                });
                game.setCompleted(false);
                widget.onNewGame(selected, forceNew: true);
              }
            },
            child: const Text('Change Difficulty'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isNoteMode = false;
                _congratsShown = false;
              });
              game.setCompleted(false);
              widget.onNewGame(game.difficulty, forceNew: true);
            },
            child: const Text('New Puzzle'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => LandingScreen(onStartGame: widget.onNewGame),
                ),
                (route) => false,
              );
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }

  void _replaceGame(SudokuGame newGame) {}

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event, SudokuGame game) {
    _resetInactivityTimer();
    final key = event.logicalKey;
    
    // Handle undo/redo shortcuts
    if (event is RawKeyDownEvent) {
      final isMetaPressed = event.isMetaPressed;
      final isShiftPressed = event.isShiftPressed;
      
      // Cmd+Z for undo
      if (isMetaPressed && !isShiftPressed && key == LogicalKeyboardKey.keyZ) {
        if (game.canUndo()) {
          setState(() {
            game.undo();
          });
        }
        return KeyEventResult.handled;
      }
      
      // Shift+Cmd+Z for redo
      if (isMetaPressed && isShiftPressed && key == LogicalKeyboardKey.keyZ) {
        if (game.canRedo()) {
          setState(() {
            game.redo();
          });
        }
        return KeyEventResult.handled;
      }
    }

    // Handle shift key for temporary mode switch
    if (key == LogicalKeyboardKey.shiftLeft || key == LogicalKeyboardKey.shiftRight) {
      if (event is RawKeyDownEvent && !_shiftHeld) {
        setState(() => _shiftHeld = true);
      } else if (event is RawKeyUpEvent && _shiftHeld) {
        setState(() => _shiftHeld = false);
      }
      return KeyEventResult.handled;
    }
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    // Number keys 1-9
    bool effectiveNoteMode = _shiftHeld ? !isNoteMode : isNoteMode;
    if (key.keyId >= LogicalKeyboardKey.digit1.keyId && key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      final number = key.keyId - LogicalKeyboardKey.digit1.keyId + 1;
      if (game.selectedRow != null && game.selectedCol != null) {
        if (effectiveNoteMode) {
          game.toggleNote(game.selectedRow!, game.selectedCol!, number);
        } else {
          game.setValue(game.selectedRow!, game.selectedCol!, number);
        }
      }
      return KeyEventResult.handled;
    }
    // Numpad keys 1-9
    if (key.keyId >= LogicalKeyboardKey.numpad1.keyId && key.keyId <= LogicalKeyboardKey.numpad9.keyId) {
      final number = key.keyId - LogicalKeyboardKey.numpad1.keyId + 1;
      if (game.selectedRow != null && game.selectedCol != null) {
        if (effectiveNoteMode) {
          game.toggleNote(game.selectedRow!, game.selectedCol!, number);
        } else {
          game.setValue(game.selectedRow!, game.selectedCol!, number);
        }
      }
      return KeyEventResult.handled;
    }
    // Arrow keys
    if (game.selectedRow != null && game.selectedCol != null) {
      if (key == LogicalKeyboardKey.arrowUp) {
        setState(() => game.setSelectedCell((game.selectedRow! - 1).clamp(0, 8), game.selectedCol!));
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        setState(() => game.setSelectedCell((game.selectedRow! + 1).clamp(0, 8), game.selectedCol!));
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        setState(() => game.setSelectedCell(game.selectedRow!, (game.selectedCol! - 1).clamp(0, 8)));
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight) {
        setState(() => game.setSelectedCell(game.selectedRow!, (game.selectedCol! + 1).clamp(0, 8)));
        return KeyEventResult.handled;
      }
    }
    // If arrow key pressed but no cell is selected, handle it so focus doesn't leave board
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.handled;
    }
    // Backspace/Delete
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      if (game.selectedRow != null && game.selectedCol != null) {
        game.clearCell(game.selectedRow!, game.selectedCol!);
      }
      return KeyEventResult.handled;
    }
    // Space bar toggles note mode
    if (key == LogicalKeyboardKey.space) {
      setState(() => isNoteMode = !isNoteMode);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    // Only save if the game isn't completed
    if (!_game.isCompleted) {
      _saveDebounceTimer?.cancel();
      _saveGame();
    } else {
      _clearSavedGame();
    }
    _game.setPaused(true);
    _focusNode.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    // Only save if the game isn't completed
    if (!_game.isCompleted) {
      _game.setPaused(true);
      _saveGame();
    } else {
      _clearSavedGame();
    }
    super.deactivate();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    
    // Only reset timer on actual user interaction and when the screen is visible
    if (ModalRoute.of(context)?.isCurrent == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetInactivityTimer());
    }

    return Consumer<SudokuGame>(
      builder: (context, game, _) {
        // Move dialog logic to a separate method to reduce build complexity
        _handleGameStateChanges(game);
        
        return Scaffold(
          appBar: _buildAppBar(context, game),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _resetInactivityTimer,
            onPanDown: (_) => _resetInactivityTimer(),
            child: Column(
              children: [
                if (!settings.hideTimer) const TimerWidget(),
                Expanded(
                  child: _buildGameContent(context, game),
                ),
                const AppFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Game Paused'),
        content: const Text('Press Resume to continue playing.'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<SudokuGame>(context, listen: false).setPaused(false);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(BuildContext context, SudokuGame game) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (node, event) => _handleKeyEvent(node, event, game),
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Column(
          children: [
            Expanded(
              child: SudokuBoard(
                key: ValueKey(game.id), // Add key to prevent unnecessary rebuilds
                game: game,
                selectedRow: game.selectedRow,
                selectedCol: game.selectedCol,
                onCellSelected: (row, col) {
                  game.setSelectedCell(row, col);
                  _focusNode.requestFocus();
                },
              ),
            ),
            NumberPad(
              key: ValueKey('${game.id}_$isNoteMode'), // Add key to prevent unnecessary rebuilds
              isNoteMode: isNoteMode,
              onNumberPressed: (number) {
                if (game.selectedRow != null && game.selectedCol != null) {
                  if (_shiftHeld ? !isNoteMode : isNoteMode) {
                    game.toggleNote(game.selectedRow!, game.selectedCol!, number);
                  } else {
                    game.setValue(game.selectedRow!, game.selectedCol!, number);
                  }
                }
              },
              onClearPressed: () {
                if (game.selectedRow != null && game.selectedCol != null) {
                  game.clearCell(game.selectedRow!, game.selectedCol!);
                }
              },
              onNoteModeToggled: () {
                setState(() => isNoteMode = !isNoteMode);
              },
              onUndo: game.canUndo() ? () {
                setState(() => game.undo());
              } : null,
              onRedo: game.canRedo() ? () {
                setState(() => game.redo());
              } : null,
              usedNumbersBoard: game.puzzle,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SudokuGame game) {
    return AppBar(
      title: const Text(
        'Based Sudoku',
        style: TextStyle(
          fontFamily: 'Cubano',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => LandingScreen(onStartGame: widget.onNewGame),
            ),
            (route) => false,
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: NordColors.nord6),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: NordColors.nord6),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SettingsPage(onNewGame: widget.onNewGame)),
            );
          },
        ),
        _buildGameMenu(context, game),
      ],
    );
  }

  Widget _buildGameMenu(BuildContext context, SudokuGame game) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'reset') {
          _resetGame(game);
        } else if (value == 'new') {
          widget.onNewGame(widget.difficulty, forceNew: true);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'reset',
          child: Text('Reset Puzzle'),
        ),
        PopupMenuItem<String>(
          value: 'new',
          child: Text('New Puzzle'),
        ),
      ],
    );
  }

  void _resetGame(SudokuGame game) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (!game.isFixed[i][j]) {
          game.puzzle[i][j] = 0;
          game.notes[i][j].clear();
        }
      }
    }
    game.moveHistory.clear();
    game.redoHistory.clear();
    game.setSelectedCell(null, null);
    game.notifyListeners();
  }
} 