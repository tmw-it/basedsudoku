import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_game.dart';
import '../theme/nord_theme.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  List<List<int>>? _lastPuzzleRef;
  SudokuGame? _game;

  @override
  void initState() {
    super.initState();
    _game = context.read<SudokuGame>();
    _elapsed = _game!.timeElapsed;
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final game = context.watch<SudokuGame>();
    _game = game;
    if (_lastPuzzleRef != game.puzzle) {
      setState(() {
        _elapsed = game.timeElapsed;
        _lastPuzzleRef = game.puzzle;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_game != null && _elapsed != _game!.timeElapsed) {
      _game!.setTimeElapsed(_elapsed);
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      final game = _game;
      if (game == null || game.isPaused || game.isCompleted) return;

      setState(() {
        _elapsed += const Duration(seconds: 1);
        if (_elapsed != game.timeElapsed) {
          game.setTimeElapsed(_elapsed);
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return '${twoDigits(hours)}:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<SudokuGame>(
      builder: (context, game, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: isDark ? NordColors.nord1 : NordColors.nord4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(_elapsed),
                style: TextStyle(
                  color: isDark ? NordColors.nord6 : NordColors.nord0,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  game.isPaused ? Icons.play_arrow : Icons.pause,
                  color: isDark ? NordColors.nord6 : NordColors.nord0,
                ),
                onPressed: () {
                  context.read<SudokuGame>().setPaused(!game.isPaused);
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 