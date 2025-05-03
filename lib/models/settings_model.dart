import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sudoku_game.dart';

class SettingsModel extends ChangeNotifier {
  bool highlightRowCol = true;
  bool highlightBox = true;
  bool highlightMatchingNumbers = true;
  bool hideTimer = false;
  bool isDarkMode = false;
  bool highlightConflicts = true;
  Difficulty difficulty = Difficulty.easy;
  int pauseDelaySeconds = 30;

  SettingsModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    highlightRowCol = prefs.getBool('highlightRowCol') ?? true;
    highlightBox = prefs.getBool('highlightBox') ?? true;
    highlightMatchingNumbers = prefs.getBool('highlightMatchingNumbers') ?? true;
    hideTimer = prefs.getBool('hideTimer') ?? false;
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    highlightConflicts = prefs.getBool('highlightConflicts') ?? true;
    difficulty = Difficulty.values[prefs.getInt('difficulty') ?? 0];
    pauseDelaySeconds = prefs.getInt('pauseDelaySeconds') ?? 30;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('highlightRowCol', highlightRowCol);
    prefs.setBool('highlightBox', highlightBox);
    prefs.setBool('highlightMatchingNumbers', highlightMatchingNumbers);
    prefs.setBool('hideTimer', hideTimer);
    prefs.setBool('isDarkMode', isDarkMode);
    prefs.setBool('highlightConflicts', highlightConflicts);
    prefs.setInt('difficulty', difficulty.index);
    prefs.setInt('pauseDelaySeconds', pauseDelaySeconds);
  }

  void toggleHighlightRowCol() {
    highlightRowCol = !highlightRowCol;
    _saveSettings();
    notifyListeners();
  }

  void toggleHighlightBox() {
    highlightBox = !highlightBox;
    _saveSettings();
    notifyListeners();
  }

  void toggleHighlightMatchingNumbers() {
    highlightMatchingNumbers = !highlightMatchingNumbers;
    _saveSettings();
    notifyListeners();
  }

  void toggleHideTimer() {
    hideTimer = !hideTimer;
    _saveSettings();
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    _saveSettings();
    notifyListeners();
  }

  void toggleHighlightConflicts() {
    highlightConflicts = !highlightConflicts;
    _saveSettings();
    notifyListeners();
  }

  void setDifficulty(Difficulty d) {
    difficulty = d;
    _saveSettings();
    notifyListeners();
  }

  void setPauseDelaySeconds(int seconds) {
    pauseDelaySeconds = seconds;
    _saveSettings();
    notifyListeners();
  }
} 