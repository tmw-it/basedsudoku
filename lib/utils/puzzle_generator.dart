import 'dart:math';
import '../models/sudoku_game.dart';

class PuzzleGenerator {
  static final Random _random = Random();

  static List<List<int>> generateSolution() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonal(grid);
    _solveSudoku(grid);
    return grid;
  }

  static void _fillDiagonal(List<List<int>> grid) {
    for (int i = 0; i < 9; i += 3) {
      _fillBox(grid, i, i);
    }
  }

  static void _fillBox(List<List<int>> grid, int row, int col) {
    List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(_random);
    int index = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        grid[row + i][col + j] = numbers[index++];
      }
    }
  }

  static bool _solveSudoku(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (int num in numbers) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_solveSudoku(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // Check row
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num) return false;
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      if (grid[i][col] == num) return false;
    }

    // Check 3x3 box
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[boxRow + i][boxCol + j] == num) return false;
      }
    }

    return true;
  }

  static List<List<int>> generatePuzzle(Difficulty difficulty) {
    List<List<int>> solution = generateSolution();
    List<List<int>> puzzle = List.generate(
      9,
      (i) => List.generate(9, (j) => solution[i][j]),
    );

    int cellsToRemove;
    switch (difficulty) {
      case Difficulty.easy:
        cellsToRemove = 30;
        break;
      case Difficulty.medium:
        cellsToRemove = 40;
        break;
      case Difficulty.hard:
        cellsToRemove = 50;
        break;
      case Difficulty.master:
        cellsToRemove = 55;
        break;
      case Difficulty.evil:
        cellsToRemove = 60;
        break;
    }

    List<int> positions = List.generate(81, (i) => i)..shuffle(_random);
    for (int i = 0; i < cellsToRemove; i++) {
      int pos = positions[i];
      int row = pos ~/ 9;
      int col = pos % 9;
      puzzle[row][col] = 0;
    }

    return puzzle;
  }

  // Helper to count solutions (returns at most 2)
  static int countSolutions(List<List<int>> grid, [int limit = 2]) {
    int count = 0;
    void solve() {
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (grid[row][col] == 0) {
            for (int num = 1; num <= 9; num++) {
              if (_isValid(grid, row, col, num)) {
                grid[row][col] = num;
                solve();
                grid[row][col] = 0;
                if (count >= limit) return;
              }
            }
            return;
          }
        }
      }
      count++;
    }
    solve();
    return count;
  }

  static SudokuGame generateGame(Difficulty difficulty) {
    List<List<int>> solution = generateSolution();
    // Make a deep copy for the puzzle
    List<List<int>> puzzle = List.generate(
      9,
      (i) => List.generate(9, (j) => solution[i][j]),
    );

    int cellsToRemove;
    switch (difficulty) {
      case Difficulty.easy:
        cellsToRemove = 30;
        break;
      case Difficulty.medium:
        cellsToRemove = 40;
        break;
      case Difficulty.hard:
        cellsToRemove = 50;
        break;
      case Difficulty.master:
        cellsToRemove = 55;
        break;
      case Difficulty.evil:
        cellsToRemove = 60;
        break;
    }

    List<int> positions = List.generate(81, (i) => i)..shuffle(_random);
    int removed = 0;
    for (int i = 0; i < positions.length && removed < cellsToRemove; i++) {
      int pos = positions[i];
      int row = pos ~/ 9;
      int col = pos % 9;
      int backup = puzzle[row][col];
      puzzle[row][col] = 0;
      // Only keep removal if puzzle still has a unique solution
      if (countSolutions(puzzle) != 1) {
        puzzle[row][col] = backup;
      } else {
        removed++;
      }
    }

    SudokuGame game = SudokuGame(
      difficulty: difficulty,
      solution: solution,
      puzzle: puzzle,
    );
    print('--- NEW GAME ---');
    print('Puzzle:');
    for (var row in game.puzzle) {
      print(row);
    }
    print('Solution:');
    for (var row in game.solution) {
      print(row);
    }
    print('isFixed:');
    for (var row in game.isFixed) {
      print(row);
    }
    return game;
  }
} 