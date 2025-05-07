import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cool_sudoku/theme/nord_theme.dart';
import 'dart:io' show Platform;

class NumberPad extends StatelessWidget {
  final bool isNoteMode;
  final Function(int) onNumberPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onNoteModeToggled;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final List<List<int>> usedNumbersBoard;

  const NumberPad({
    super.key,
    required this.isNoteMode,
    required this.onNumberPressed,
    required this.onClearPressed,
    required this.onNoteModeToggled,
    this.onUndo,
    this.onRedo,
    required this.usedNumbersBoard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? NordColors.nord3 : NordColors.nord4;
    final textColor = isDark ? NordColors.nord6 : NordColors.nord0;
    final usedNumbers = _getUsedNumbers();
    final isDesktop = !Platform.isAndroid && !Platform.isIOS;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Row 1: Undo/Redo and Notes buttons, perfectly aligned with number buttons
          SizedBox(
            width: 296, // 5*48 + 4*8
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: _buildControlButton(
                    icon: Icons.undo,
                    onPressed: onUndo,
                    color: onUndo != null ? textColor : textColor.withOpacity(0.3),
                    backgroundColor: buttonColor,
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: _buildControlButton(
                    icon: Icons.redo,
                    onPressed: onRedo,
                    color: onRedo != null ? textColor : textColor.withOpacity(0.3),
                    backgroundColor: buttonColor,
                  ),
                ),
                SizedBox(width: 8),
                const SizedBox(width: 48), // Empty above 3
                SizedBox(width: 8),
                const SizedBox(width: 48), // Empty above 4
                SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: _buildControlButton(
                    icon: isNoteMode ? Icons.edit : Icons.edit_off,
                    onPressed: onNoteModeToggled,
                    color: textColor,
                    backgroundColor: buttonColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Row 2: Numbers 1-5
          SizedBox(
            width: 296,
            child: Row(
              children: [
                for (int i = 1; i <= 5; i++) ...[
                  SizedBox(
                    width: 48,
                    child: _buildNumberButton(
                      number: i,
                      isUsed: usedNumbers.contains(i),
                      buttonColor: buttonColor,
                      textColor: textColor,
                      onPressed: () => onNumberPressed(i),
                    ),
                  ),
                  if (i != 5) SizedBox(width: 8),
                ]
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Row 3: Numbers 6-9 and Delete
          SizedBox(
            width: 296,
            child: Row(
              children: [
                for (int i = 6; i <= 9; i++) ...[
                  SizedBox(
                    width: 48,
                    child: _buildNumberButton(
                      number: i,
                      isUsed: usedNumbers.contains(i),
                      buttonColor: buttonColor,
                      textColor: textColor,
                      onPressed: () => onNumberPressed(i),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                SizedBox(
                  width: 48,
                  child: _buildControlButton(
                    icon: Icons.backspace,
                    onPressed: onClearPressed,
                    color: textColor,
                    backgroundColor: buttonColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton({
    required int number,
    required bool isUsed,
    required Color buttonColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: isUsed ? textColor.withOpacity(0.3) : textColor,
        fixedSize: const Size(48, 48),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        number.toString(),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required Color backgroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: color,
        fixedSize: const Size(48, 48),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Icon(icon, size: 24),
    );
  }

  Set<int> _getUsedNumbers() {
    final counts = <int, int>{};
    for (var row in usedNumbersBoard) {
      for (var num in row) {
        if (num != 0) {
          counts[num] = (counts[num] ?? 0) + 1;
        }
      }
    }
    // Return numbers that have been used 9 times
    return counts.entries
        .where((entry) => entry.value >= 9)
        .map((entry) => entry.key)
        .toSet();
  }
} 