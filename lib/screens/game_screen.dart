import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/models/sudoku_game.dart';
import 'package:sudoku/widgets/number_pad.dart';
import 'package:sudoku/widgets/sudoku_board.dart';
import 'package:sudoku/widgets/timer_widget.dart';
import 'package:sudoku/theme/nord_theme.dart';
import 'dart:math';
import 'package:sudoku/utils/puzzle_generator.dart';
import 'package:sudoku/screens/settings_page.dart';
import 'package:sudoku/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final void Function(Difficulty) onNewGame;

  const GameScreen({super.key, required this.difficulty, required this.onNewGame});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int? selectedRow;
  int? selectedCol;
  bool isNoteMode = false;
  bool _shiftHeld = false;
  final FocusNode _focusNode = FocusNode();
  bool _congratsShown = false;
  Timer? _inactivityTimer;

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
    // Try to get the timer from TimerWidget, fallback to 0 if not found
    int seconds = 0;
    try {
      // TimerWidget is not directly accessible, so use 0 for now
      // Optionally, you could pass the timeElapsed to SudokuGame on completion
    } catch (_) {}
    // If you add a timeElapsed to SudokuGame, use: int seconds = game.timeElapsed.inSeconds;
    // For now, just increment games
    games++;
    // Only update best if seconds > 0
    if (seconds > 0 && (best == null || seconds < best)) best = seconds;
    if (seconds > 0) total += seconds;
    await prefs.setInt(gamesKey, games);
    if (best != null) await prefs.setInt(bestKey, best);
    await prefs.setInt(totalKey, total);
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
                        items: [
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
                  selectedRow = null;
                  selectedCol = null;
                  isNoteMode = false;
                  _congratsShown = false;
                });
                widget.onNewGame(selected);
              }
            },
            child: const Text('Change Difficulty'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                selectedRow = null;
                selectedCol = null;
                isNoteMode = false;
                _congratsShown = false;
              });
              widget.onNewGame(game.difficulty);
            },
            child: const Text('New Puzzle'),
          ),
        ],
      ),
    );
  }

  void _replaceGame(SudokuGame newGame) {}

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event, SudokuGame game) {
    _resetInactivityTimer();
    final key = event.logicalKey;
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
      if (selectedRow != null && selectedCol != null) {
        if (effectiveNoteMode) {
          game.toggleNote(selectedRow!, selectedCol!, number);
        } else {
          game.setValue(selectedRow!, selectedCol!, number);
        }
      }
      return KeyEventResult.handled;
    }
    // Numpad keys 1-9
    if (key.keyId >= LogicalKeyboardKey.numpad1.keyId && key.keyId <= LogicalKeyboardKey.numpad9.keyId) {
      final number = key.keyId - LogicalKeyboardKey.numpad1.keyId + 1;
      if (selectedRow != null && selectedCol != null) {
        if (effectiveNoteMode) {
          game.toggleNote(selectedRow!, selectedCol!, number);
        } else {
          game.setValue(selectedRow!, selectedCol!, number);
        }
      }
      return KeyEventResult.handled;
    }
    // Arrow keys
    if (selectedRow != null && selectedCol != null) {
      if (key == LogicalKeyboardKey.arrowUp && selectedRow! > 0) {
        setState(() => selectedRow = selectedRow! - 1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown && selectedRow! < 8) {
        setState(() => selectedRow = selectedRow! + 1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft && selectedCol! > 0) {
        setState(() => selectedCol = selectedCol! - 1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight && selectedCol! < 8) {
        setState(() => selectedCol = selectedCol! + 1);
        return KeyEventResult.handled;
      }
    }
    // Backspace/Delete
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      if (selectedRow != null && selectedCol != null) {
        game.clearCell(selectedRow!, selectedCol!);
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

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    final settings = Provider.of<SettingsModel>(context, listen: false);
    _inactivityTimer = Timer(Duration(seconds: settings.pauseDelaySeconds), () {
      if (!mounted) return;
      Provider.of<SudokuGame>(context, listen: false).setPaused(true);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    // Reset inactivity timer on every build (user interaction)
    WidgetsBinding.instance.addPostFrameCallback((_) => _resetInactivityTimer());
    return Consumer<SudokuGame>(
      builder: (context, game, _) {
        print('GameScreen build: isCompleted=${game.isCompleted}, isPaused=${game.isPaused}, _congratsShown=$_congratsShown');
        // Robust congrats dialog logic
        if (game.isCompleted && !_congratsShown && !game.isPaused) {
          print('Attempting to show congrats dialog...');
          Future.delayed(Duration.zero, () {
            if (mounted && !_congratsShown && !game.isPaused) {
              print('Showing congrats dialog!');
              _showCongratsDialog(context, game);
              setState(() {
                _congratsShown = true;
              });
            }
          });
        }
        if (!game.isCompleted && _congratsShown) {
          print('Resetting _congratsShown');
          _congratsShown = false;
        }
        // Show pause dialog if paused
        if (game.isPaused) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.isCurrent == true) {
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
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sudoku'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Provider.of<SudokuGame>(context, listen: false).setPaused(true);
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: NordColors.nord6),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsPage(onNewGame: widget.onNewGame)),
                  );
                },
              ),
            ],
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _resetInactivityTimer,
            onPanDown: (_) => _resetInactivityTimer(),
            child: Column(
              children: [
                if (!settings.hideTimer) const TimerWidget(),
                Expanded(
                  child: Consumer<SudokuGame>(
                    builder: (context, game, child) {
                      return Focus(
                        focusNode: _focusNode,
                        autofocus: true,
                        onKey: (node, event) => _handleKeyEvent(node, event, game),
                        child: GestureDetector(
                          onTap: () => _focusNode.requestFocus(),
                          child: Column(
                            children: [
                              Expanded(
                                child: Consumer<SudokuGame>(
                                  builder: (context, game, _) => SudokuBoard(
                                    game: game,
                                    selectedRow: selectedRow,
                                    selectedCol: selectedCol,
                                    onCellSelected: (row, col) {
                                      setState(() {
                                        selectedRow = row;
                                        selectedCol = col;
                                      });
                                      _focusNode.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                              NumberPad(
                                isNoteMode: isNoteMode,
                                onNumberPressed: (number) {
                                  if (selectedRow != null && selectedCol != null) {
                                    if (_shiftHeld ? !isNoteMode : isNoteMode) {
                                      game.toggleNote(selectedRow!, selectedCol!, number);
                                    } else {
                                      game.setValue(selectedRow!, selectedCol!, number);
                                    }
                                  }
                                },
                                onClearPressed: () {
                                  if (selectedRow != null && selectedCol != null) {
                                    game.clearCell(selectedRow!, selectedCol!);
                                  }
                                },
                                onNoteModeToggled: () {
                                  setState(() {
                                    isNoteMode = !isNoteMode;
                                  });
                                },
                                usedNumbersBoard: game.puzzle,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 