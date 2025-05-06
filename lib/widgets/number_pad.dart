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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.undo,
                onPressed: onUndo,
                color: onUndo != null ? textColor : textColor.withOpacity(0.3),
                backgroundColor: buttonColor,
              ),
              _buildControlButton(
                icon: Icons.redo,
                onPressed: onRedo,
                color: onRedo != null ? textColor : textColor.withOpacity(0.3),
                backgroundColor: buttonColor,
              ),
              _buildControlButton(
                icon: isNoteMode ? Icons.edit : Icons.edit_off,
                onPressed: onNoteModeToggled,
                color: textColor,
                backgroundColor: buttonColor,
              ),
              _buildControlButton(
                icon: Icons.backspace,
                onPressed: onClearPressed,
                color: textColor,
                backgroundColor: buttonColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isDesktop)
            // Desktop: Single row of numbers
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(9, (index) {
                final number = index + 1;
                final isUsed = usedNumbers.contains(number);
                return _buildNumberButton(
                  number: number,
                  isUsed: isUsed,
                  buttonColor: buttonColor,
                  textColor: textColor,
                  onPressed: () => onNumberPressed(number),
                );
              }),
            )
          else
            // Mobile: Two rows of numbers
            Column(
              children: [
                // First row: 1-5
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(5, (index) {
                    final number = index + 1;
                    final isUsed = usedNumbers.contains(number);
                    return _buildNumberButton(
                      number: number,
                      isUsed: isUsed,
                      buttonColor: buttonColor,
                      textColor: textColor,
                      onPressed: () => onNumberPressed(number),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Second row: 6-9
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(4, (index) {
                    final number = index + 6;
                    final isUsed = usedNumbers.contains(number);
                    return _buildNumberButton(
                      number: number,
                      isUsed: isUsed,
                      buttonColor: buttonColor,
                      textColor: textColor,
                      onPressed: () => onNumberPressed(number),
                    );
                  }),
                ),
              ],
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
        minimumSize: const Size(48, 48),
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
        minimumSize: const Size(48, 48),
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