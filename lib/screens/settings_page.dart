import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:based_sudoku/models/settings_model.dart';
import 'package:based_sudoku/models/sudoku_game.dart';

class SettingsPage extends StatelessWidget {
  final void Function(Difficulty, {bool forceNew})? onNewGame;
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
            title: const Text('Highlight Conflicts'),
            value: settings.highlightConflicts,
            onChanged: (_) => settings.toggleHighlightConflicts(),
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
          const Divider(),
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