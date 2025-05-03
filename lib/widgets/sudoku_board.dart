import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/theme/nord_theme.dart';
import '../models/sudoku_game.dart';
import '../models/settings_model.dart';

class SudokuBoard extends StatelessWidget {
  final SudokuGame? game;
  final List<List<int>>? board;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int, int)? onCellSelected;
  final List<List<int>>? highlightCells;
  final List<int>? solutionCell;
  final bool isReadOnly;

  const SudokuBoard({
    super.key,
    this.game,
    this.board,
    this.selectedRow,
    this.selectedCol,
    this.onCellSelected,
    this.highlightCells,
    this.solutionCell,
    this.isReadOnly = false,
  }) : assert(game != null || board != null, 'Either game or board must be provided');

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    bool isCellInConflict(int row, int col, int value) {
      if (value == 0) return false;
      final puzzle = game?.puzzle ?? board!;
      // Check row
      for (int i = 0; i < 9; i++) {
        if (i != col && puzzle[row][i] == value) return true;
      }
      // Check column
      for (int i = 0; i < 9; i++) {
        if (i != row && puzzle[i][col] == value) return true;
      }
      // Check box
      int boxRow = (row ~/ 3) * 3;
      int boxCol = (col ~/ 3) * 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          int r = boxRow + i;
          int c = boxCol + j;
          if ((r != row || c != col) && puzzle[r][c] == value) return true;
        }
      }
      return false;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        return SizedBox(
          width: size,
          height: size,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final isSelected = row == selectedRow && col == selectedCol;
                final isFixed = game?.isFixed[row][col] ?? false;
                final value = (game?.puzzle ?? board!)[row][col];
                final notes = game?.notes[row][col] ?? {};
                final selectedValue = (selectedRow != null && selectedCol != null)
                    ? (game?.puzzle ?? board!)[selectedRow!][selectedCol!]
                    : 0;

                // Highlight logic
                bool highlightRowCol = settings.highlightRowCol && (selectedRow != null && selectedCol != null) && (row == selectedRow || col == selectedCol);
                bool highlightBox = false;
                if (settings.highlightBox && selectedRow != null && selectedCol != null) {
                  int boxRow = (row ~/ 3);
                  int boxCol = (col ~/ 3);
                  int selBoxRow = (selectedRow! ~/ 3);
                  int selBoxCol = (selectedCol! ~/ 3);
                  highlightBox = (boxRow == selBoxRow && boxCol == selBoxCol);
                }
                bool highlightMatch = settings.highlightMatchingNumbers && (selectedValue != 0) && (value == selectedValue);

                // Technique example highlighting
                bool isHighlighted = highlightCells?.any((cell) => cell[0] == row && cell[1] == col) ?? false;
                bool isSolution = solutionCell != null && solutionCell![0] == row && solutionCell![1] == col;

                // Conflict logic
                bool isConflict = settings.highlightConflicts && isCellInConflict(row, col, value);

                Color bgColor = Colors.transparent;
                Color textColor;
                FontWeight fontWeight = FontWeight.normal;
                if (isFixed) {
                  textColor = isDark ? NordColors.nord6 : NordColors.nord0;
                  fontWeight = FontWeight.bold;
                } else {
                  textColor = isDark ? NordColors.nord8 : NordColors.nord10;
                }

                if (isSelected) {
                  bgColor = isDark ? NordColors.nord10 : NordColors.nord8;
                  textColor = isDark ? NordColors.nord6 : NordColors.nord6;
                  fontWeight = isFixed ? FontWeight.bold : FontWeight.normal;
                } else if (isHighlighted) {
                  bgColor = NordColors.nord13;
                  textColor = NordColors.nord0;
                } else if (isSolution) {
                  bgColor = NordColors.nord14;
                  textColor = NordColors.nord0;
                } else if (highlightMatch) {
                  bgColor = NordColors.nord13;
                  textColor = NordColors.nord0;
                } else if (highlightRowCol || highlightBox) {
                  bgColor = isDark ? NordColors.nord3 : NordColors.nord4;
                  textColor = isFixed
                      ? (isDark ? NordColors.nord6 : NordColors.nord0)
                      : (isDark ? NordColors.nord8 : NordColors.nord10);
                  fontWeight = isFixed ? FontWeight.bold : FontWeight.normal;
                }

                // Grid line logic
                Color borderColor = isDark ? NordColors.nord4 : NordColors.nord3;
                double borderWidth = 0.5;
                // Bolder lines for box boundaries
                if (row % 3 == 0) {
                  borderWidth = 2.0;
                  borderColor = isDark ? NordColors.nord6 : NordColors.nord0;
                }
                if (col % 3 == 0) {
                  // If both row and col are box boundaries, make it even bolder
                  borderWidth = 2.0;
                  borderColor = isDark ? NordColors.nord6 : NordColors.nord0;
                }

                return GestureDetector(
                  onTap: isReadOnly ? null : () => onCellSelected?.call(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border(
                        top: BorderSide(
                          color: row % 3 == 0 ? (isDark ? NordColors.nord6 : NordColors.nord0) : (isDark ? NordColors.nord4 : NordColors.nord3),
                          width: row % 3 == 0 ? 2.0 : 0.5,
                        ),
                        left: BorderSide(
                          color: col % 3 == 0 ? (isDark ? NordColors.nord6 : NordColors.nord0) : (isDark ? NordColors.nord4 : NordColors.nord3),
                          width: col % 3 == 0 ? 2.0 : 0.5,
                        ),
                        right: BorderSide(
                          color: (col == 8) ? (isDark ? NordColors.nord6 : NordColors.nord0) : Colors.transparent,
                          width: (col == 8) ? 2.0 : 0.0,
                        ),
                        bottom: BorderSide(
                          color: (row == 8) ? (isDark ? NordColors.nord6 : NordColors.nord0) : Colors.transparent,
                          width: (row == 8) ? 2.0 : 0.0,
                        ),
                      ),
                    ),
                    child: value != 0
                        ? Stack(
                            children: [
                              Center(
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: fontWeight,
                                  ),
                                ),
                              ),
                              if (isConflict && value != 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : _buildNotes(context, notes),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getCellColor(int row, int col, bool isSelected) {
    if (isSelected) {
      return NordColors.nord10;
    }

    final boxRow = row ~/ 3;
    final boxCol = col ~/ 3;
    final isAlternateBox = (boxRow + boxCol) % 2 == 1;

    return isAlternateBox
        ? NordColors.nord1
        : NordColors.nord0;
  }

  Widget _buildNotes(BuildContext context, Set<int> notes) {
    if (notes.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteColor = isDark
        ? NordColors.nord6.withOpacity(0.7)
        : NordColors.nord0.withOpacity(0.7);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final number = index + 1;
        final hasNote = notes.contains(number);

        return Center(
          child: Text(
            hasNote ? number.toString() : '',
            style: TextStyle(
              color: noteColor,
              fontSize: 10,
            ),
          ),
        );
      },
    );
  }
} 