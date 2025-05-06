import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cool_sudoku/models/sudoku_game.dart';
import 'package:cool_sudoku/screens/game_screen.dart';
import 'package:cool_sudoku/screens/techniques_page.dart';
import 'package:cool_sudoku/screens/settings_page.dart';
import 'package:cool_sudoku/theme/nord_theme.dart';
import 'package:cool_sudoku/widgets/app_footer.dart';
import 'package:cool_sudoku/screens/about_page.dart';

class LandingScreen extends StatefulWidget {
  final void Function(Difficulty) onStartGame;

  const LandingScreen({super.key, required this.onStartGame});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Map<Difficulty, Map<String, int>> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = <Difficulty, Map<String, int>>{};
    for (final diff in Difficulty.values) {
      final games = prefs.getInt('stats_${diff.name}_games') ?? 0;
      final best = prefs.getInt('stats_${diff.name}_best');
      final total = prefs.getInt('stats_${diff.name}_total') ?? 0;
      stats[diff] = {
        'games': games,
        'best': best ?? 0,
        'total': total,
      };
    }
    setState(() {
      _stats = stats;
    });
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return '--:--';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatAverage(int total, int games) {
    if (games == 0) return '--:--';
    final average = total ~/ games;
    return _formatTime(average);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cool Sudoku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Difficulty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                children: [
                  ...Difficulty.values.map((difficulty) {
                    final stats = _stats[difficulty] ?? {'games': 0, 'best': 0, 'total': 0};
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => widget.onStartGame(difficulty),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      difficulty.name[0].toUpperCase() + difficulty.name.substring(1),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Games: ${stats['games']}'),
                                        Text('Best: ${_formatTime(stats['best']!)}'),
                                        Text('Avg: ${_formatAverage(stats['total']!, stats['games']!)}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TechniquesPage()),
                          );
                        },
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Techniques'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SettingsPage(onNewGame: widget.onStartGame)),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
} 