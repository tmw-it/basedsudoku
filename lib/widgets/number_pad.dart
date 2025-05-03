import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/theme/nord_theme.dart';

class NumberPad extends StatelessWidget {
  final bool isNoteMode;
  final Function(int) onNumberPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onNoteModeToggled;
  final List<List<int>>? usedNumbersBoard;

  const NumberPad({
    super.key,
    required this.isNoteMode,
    required this.onNumberPressed,
    required this.onClearPressed,
    required this.onNoteModeToggled,
    this.usedNumbersBoard,
  });

  Map<int, int> _countNumbers() {
    final Map<int, int> counts = {for (var i = 1; i <= 9; i++) i: 0};
    if (usedNumbersBoard != null) {
      for (var row in usedNumbersBoard!) {
        for (var val in row) {
          if (val >= 1 && val <= 9) counts[val] = counts[val]! + 1;
        }
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final usedCounts = _countNumbers();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: isDark ? NordColors.nord1 : NordColors.nord4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.edit,
                isActive: isNoteMode,
                onPressed: onNoteModeToggled,
                isDark: isDark,
              ),
              _buildControlButton(
                icon: Icons.backspace,
                onPressed: onClearPressed,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(
              9,
              (index) => _buildNumberButton(index + 1, usedCounts[index + 1] == 9, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number, bool isUsedUp, bool isDark) {
    return Material(
      color: isUsedUp ? NordColors.nord14 : (isDark ? NordColors.nord0 : NordColors.nord6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isUsedUp ? null : () => onNumberPressed(number),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isUsedUp ? (isDark ? NordColors.nord0 : NordColors.nord6) : (isDark ? NordColors.nord6 : NordColors.nord0),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    bool isActive = false,
    required VoidCallback onPressed,
    bool isDark = false,
  }) {
    return Material(
      color: isActive ? NordColors.nord10 : (isDark ? NordColors.nord0 : NordColors.nord6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isActive ? (isDark ? NordColors.nord6 : NordColors.nord0) : (isDark ? NordColors.nord4 : NordColors.nord3),
          ),
        ),
      ),
    );
  }
} 