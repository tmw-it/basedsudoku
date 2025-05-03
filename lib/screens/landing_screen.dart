import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/models/sudoku_game.dart';
import 'package:sudoku/screens/game_screen.dart';
import 'package:sudoku/screens/techniques_page.dart';

class LandingScreen extends StatefulWidget {
  final void Function(Difficulty) onStartGame;
  const LandingScreen({super.key, required this.onStartGame});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Difficulty _selected = Difficulty.easy;
  Map<Difficulty, Map<String, dynamic>> stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      stats = {
        for (var d in Difficulty.values)
          d: {
            'games': prefs.getInt('stats_${d.name}_games') ?? 0,
            'best': prefs.getInt('stats_${d.name}_best') ?? null,
            'total': prefs.getInt('stats_${d.name}_total') ?? 0,
          }
      };
    });
  }

  String _formatTime(int? seconds) {
    if (seconds == null || seconds == 0) return '--';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text('Select Difficulty', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (var d in Difficulty.values)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          widget.onStartGame(d);
                        },
                        child: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message: techniques
                            .where((t) => t.relevantDifficulties.contains(d))
                            .map((t) => t.name)
                            .join(', '),
                        child: Icon(Icons.info_outline, size: 18),
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TechniquesPage(),
                      ),
                    );
                  },
                  child: const Text('Techniques'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Your Stats', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: Difficulty.values.map((d) {
                  final s = stats[d] ?? {};
                  final games = s['games'] ?? 0;
                  final best = s['best'] ?? null;
                  final total = s['total'] ?? 0;
                  final avg = (games > 0) ? (total ~/ games) : null;
                  return Card(
                    child: ListTile(
                      title: Text('${d.name[0].toUpperCase()}${d.name.substring(1)}'),
                      subtitle: Text('Games: $games  |  Best: ${_formatTime(best)}  |  Avg: ${_formatTime(avg)}'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 