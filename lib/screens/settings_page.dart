import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/models/settings_model.dart';
import 'package:sudoku/models/sudoku_game.dart';

class SettingsPage extends StatelessWidget {
  final void Function(Difficulty)? onNewGame;
  const SettingsPage({super.key, this.onNewGame});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Highlight Row & Column'),
            value: settings.highlightRowCol,
            onChanged: (_) => settings.toggleHighlightRowCol(),
          ),
          SwitchListTile(
            title: const Text('Highlight Box'),
            value: settings.highlightBox,
            onChanged: (_) => settings.toggleHighlightBox(),
          ),
          SwitchListTile(
            title: const Text('Highlight Matching Numbers'),
            value: settings.highlightMatchingNumbers,
            onChanged: (_) => settings.toggleHighlightMatchingNumbers(),
          ),
          SwitchListTile(
            title: const Text('Hide Timer'),
            value: settings.hideTimer,
            onChanged: (_) => settings.toggleHideTimer(),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (_) => settings.toggleDarkMode(),
          ),
          SwitchListTile(
            title: const Text('Highlight Conflicts'),
            value: settings.highlightConflicts,
            onChanged: (_) => settings.toggleHighlightConflicts(),
          ),
          const Divider(),
          ListTile(
            title: const Text('Difficulty'),
            trailing: DropdownButton<Difficulty>(
              value: settings.difficulty,
              onChanged: (d) {
                if (d != null) {
                  settings.setDifficulty(d);
                  if (onNewGame != null) onNewGame!(d);
                }
              },
              items: [
                DropdownMenuItem(
                  value: Difficulty.easy,
                  child: Text('Easy'),
                ),
                DropdownMenuItem(
                  value: Difficulty.medium,
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: Difficulty.hard,
                  child: Text('Hard'),
                ),
                DropdownMenuItem(
                  value: Difficulty.master,
                  child: Text('Master'),
                ),
                DropdownMenuItem(
                  value: Difficulty.evil,
                  child: Text('Evil'),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Auto-Pause Delay'),
            subtitle: const Text('Pause timer after inactivity'),
            trailing: DropdownButton<int>(
              value: settings.pauseDelaySeconds,
              onChanged: (v) {
                if (v != null) settings.setPauseDelaySeconds(v);
              },
              items: const [
                DropdownMenuItem(value: 30, child: Text('30 seconds')),
                DropdownMenuItem(value: 60, child: Text('1 minute')),
                DropdownMenuItem(value: 120, child: Text('2 minutes')),
                DropdownMenuItem(value: 300, child: Text('5 minutes')),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 