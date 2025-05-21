import 'dart:math';
import '../models/sudoku_game.dart';

// Define the CachedPuzzle class at the top level
class CachedPuzzle {
  final List<List<int>> puzzle;
  final List<List<int>> solution;
  CachedPuzzle(this.puzzle, this.solution);
}

class PuzzleGenerator {
  static final Random _random = Random();

  // Update cache type definitions
  static final List<CachedPuzzle> _masterPuzzleCache = [];
  static final List<CachedPuzzle> _evilPuzzleCache = [];
  static const int _maxCacheSize = 5;
  static bool _isGenerating = false;

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

  // Basic human-style solver: only naked/hidden singles
  static bool isSolvableBySinglesOnly(List<List<int>> puzzle) {
    List<List<int>> board = List.generate(9, (i) => List.generate(9, (j) => puzzle[i][j]));
    bool progress = true;
    while (progress) {
      progress = false;
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (board[row][col] == 0) {
            Set<int> candidates = _getCandidates(board, row, col);
            if (candidates.length == 1) {
              board[row][col] = candidates.first;
              progress = true;
            }
          }
        }
      }
    }
    // If any cell is still 0, singles-only could not solve it
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) return false;
      }
    }
    return true;
  }

  static Set<int> _getCandidates(List<List<int>> board, int row, int col) {
    Set<int> candidates = Set.from(List.generate(9, (i) => i + 1));
    for (int i = 0; i < 9; i++) {
      candidates.remove(board[row][i]);
      candidates.remove(board[i][col]);
    }
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        candidates.remove(board[boxRow + i][boxCol + j]);
      }
    }
    return candidates;
  }

  // Replace placeholder with real advanced technique detection
  static int countAdvancedTechniquesUsed(List<List<int>> puzzle) {
    Set<String> techniques = humanSolveTechniques(puzzle);
    // Count only advanced techniques (excluding Naked Single and Hidden Single)
    return techniques.where((t) => t != 'Naked Single' && t != 'Hidden Single').length;
  }

  static SudokuGame generateGame(Difficulty difficulty) {
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
        cellsToRemove = 64; // 81 - 17 = 64 clues removed, 17 left
        break;
    }

    // For all difficulties, remove clues only if the puzzle remains uniquely solvable
    List<int> positions = List.generate(81, (i) => i)..shuffle(_random);
    int removed = 0;
    for (int i = 0; i < positions.length && removed < cellsToRemove; i++) {
      int pos = positions[i];
      int row = pos ~/ 9;
      int col = pos % 9;
      int backup = puzzle[row][col];
      puzzle[row][col] = 0;
      if (countSolutions(puzzle) != 1) {
        puzzle[row][col] = backup;
      } else {
        removed++;
      }
    }

    // Ensure solution matches puzzle
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] != 0 && puzzle[row][col] != solution[row][col]) {
          print('Mismatch at ([0;36m$row[0m, [0;36m$col[0m): puzzle=${puzzle[row][col]}, solution=${solution[row][col]}');
          // Correct the solution to match the puzzle
          solution[row][col] = puzzle[row][col];
        }
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

  // Update preGenerateMasterPuzzles method
  static Future<void> preGenerateMasterPuzzles({int count = 2}) async {
    if (_isGenerating) return;
    _isGenerating = true;
    
    try {
      // Clear old cache if it's too large
      if (_masterPuzzleCache.length > _maxCacheSize) {
        _masterPuzzleCache.clear();
      }

      // Generate new puzzles
      for (int i = 0; i < count; i++) {
        if (_masterPuzzleCache.length >= _maxCacheSize) break;
        
        List<List<int>> solution = generateSolution();
        List<List<int>> puzzle = List.generate(
          9,
          (i) => List.generate(9, (j) => solution[i][j]),
        );
        
        // Generate puzzle with fewer attempts to reduce CPU load
        List<int> positions = List.generate(81, (i) => i)..shuffle(_random);
        int removed = 0;
        int attempts = 0;
        const maxAttempts = 100;
        
        for (int j = 0; j < positions.length && removed < 55 && attempts < maxAttempts; j++) {
          attempts++;
          int pos = positions[j];
          int row = pos ~/ 9;
          int col = pos % 9;
          int backup = puzzle[row][col];
          puzzle[row][col] = 0;
          
          if (countSolutions(puzzle) == 1) {
            removed++;
          } else {
            puzzle[row][col] = backup;
          }
          
          if (attempts % 10 == 0) {
            await Future.microtask(() {});
          }
        }
        
        _masterPuzzleCache.add(CachedPuzzle(
          List.generate(9, (i) => List.from(puzzle[i])),
          List.generate(9, (i) => List.from(solution[i]))
        ));
      }
    } finally {
      _isGenerating = false;
    }
  }

  // Update preGenerateEvilPuzzles method
  static Future<void> preGenerateEvilPuzzles({int count = 2}) async {
    if (_isGenerating) return;
    _isGenerating = true;
    
    try {
      if (_evilPuzzleCache.length > _maxCacheSize) {
        _evilPuzzleCache.clear();
      }

      for (int i = 0; i < count; i++) {
        if (_evilPuzzleCache.length >= _maxCacheSize) break;
        
        List<List<int>> solution = generateSolution();
        List<List<int>> puzzle = List.generate(
          9,
          (i) => List.generate(9, (j) => solution[i][j]),
        );
        
        List<int> positions = List.generate(81, (i) => i)..shuffle(_random);
        int removed = 0;
        int attempts = 0;
        const maxAttempts = 100;
        
        for (int j = 0; j < positions.length && removed < 64 && attempts < maxAttempts; j++) {
          attempts++;
          int pos = positions[j];
          int row = pos ~/ 9;
          int col = pos % 9;
          int backup = puzzle[row][col];
          puzzle[row][col] = 0;
          
          if (countSolutions(puzzle) == 1) {
            removed++;
          } else {
            puzzle[row][col] = backup;
          }
          
          if (attempts % 10 == 0) {
            await Future.microtask(() {});
          }
        }
        
        _evilPuzzleCache.add(CachedPuzzle(
          List.generate(9, (i) => List.from(puzzle[i])),
          List.generate(9, (i) => List.from(solution[i]))
        ));
      }
    } finally {
      _isGenerating = false;
    }
  }

  // Clear caches when memory pressure is detected
  static void clearCaches() {
    _masterPuzzleCache.clear();
    _evilPuzzleCache.clear();
  }

  // --- Human-style solver core ---
  static Set<String> humanSolveTechniques(List<List<int>> puzzle) {
    Set<String> techniques = {};
    List<List<int>> board = List.generate(9, (i) => List.generate(9, (j) => puzzle[i][j]));
    List<List<Set<int>>> candidates = List.generate(9, (i) => List.generate(9, (j) => <int>{}));
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          candidates[row][col] = _getCandidates(board, row, col);
        }
      }
    }
    bool progress = true;
    while (progress) {
      progress = false;
      // 1. Naked singles
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (board[row][col] == 0 && candidates[row][col].length == 1) {
            board[row][col] = candidates[row][col].first;
            techniques.add('Naked Single');
            for (int k = 0; k < 9; k++) {
              candidates[row][k].remove(board[row][col]);
              candidates[k][col].remove(board[row][col]);
            }
            int boxRow = (row ~/ 3) * 3;
            int boxCol = (col ~/ 3) * 3;
            for (int i = 0; i < 3; i++) {
              for (int j = 0; j < 3; j++) {
                candidates[boxRow + i][boxCol + j].remove(board[row][col]);
              }
            }
            candidates[row][col].clear();
            progress = true;
          }
        }
      }
      if (progress) continue;
      // 2. Hidden singles
      for (int unit = 0; unit < 9; unit++) {
        Map<int, List<int>> candidatePositions = {};
        for (int num = 1; num <= 9; num++) {
          candidatePositions[num] = [];
        }
        for (int col = 0; col < 9; col++) {
          if (board[unit][col] == 0) {
            for (int cand in candidates[unit][col]) {
              candidatePositions[cand]!.add(col);
            }
          }
        }
        for (int num = 1; num <= 9; num++) {
          if (candidatePositions[num]!.length == 1) {
            int col = candidatePositions[num]!.first;
            board[unit][col] = num;
            techniques.add('Hidden Single');
            for (int k = 0; k < 9; k++) {
              candidates[unit][k].remove(num);
              candidates[k][col].remove(num);
            }
            int boxRow = (unit ~/ 3) * 3;
            int boxCol = (col ~/ 3) * 3;
            for (int i = 0; i < 3; i++) {
              for (int j = 0; j < 3; j++) {
                candidates[boxRow + i][boxCol + j].remove(num);
              }
            }
            candidates[unit][col].clear();
            progress = true;
          }
        }
        candidatePositions = {};
        for (int num = 1; num <= 9; num++) {
          candidatePositions[num] = [];
        }
        for (int row = 0; row < 9; row++) {
          if (board[row][unit] == 0) {
            for (int cand in candidates[row][unit]) {
              candidatePositions[cand]!.add(row);
            }
          }
        }
        for (int num = 1; num <= 9; num++) {
          if (candidatePositions[num]!.length == 1) {
            int row = candidatePositions[num]!.first;
            board[row][unit] = num;
            techniques.add('Hidden Single');
            for (int k = 0; k < 9; k++) {
              candidates[row][k].remove(num);
              candidates[k][unit].remove(num);
            }
            int boxRow = (row ~/ 3) * 3;
            int boxCol = (unit ~/ 3) * 3;
            for (int i = 0; i < 3; i++) {
              for (int j = 0; j < 3; j++) {
                candidates[boxRow + i][boxCol + j].remove(num);
              }
            }
            candidates[row][unit].clear();
            progress = true;
          }
        }
        candidatePositions = {};
        for (int num = 1; num <= 9; num++) {
          candidatePositions[num] = [];
        }
        int boxRow = (unit ~/ 3) * 3;
        int boxCol = (unit % 3) * 3;
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int row = boxRow + i;
            int col = boxCol + j;
            if (board[row][col] == 0) {
              for (int cand in candidates[row][col]) {
                candidatePositions[cand]!.add(9 * i + j);
              }
            }
          }
        }
        for (int num = 1; num <= 9; num++) {
          if (candidatePositions[num]!.length == 1) {
            int pos = candidatePositions[num]!.first;
            int row = boxRow + (pos ~/ 3);
            int col = boxCol + (pos % 3);
            board[row][col] = num;
            techniques.add('Hidden Single');
            for (int k = 0; k < 9; k++) {
              candidates[row][k].remove(num);
              candidates[k][col].remove(num);
            }
            int bRow = (row ~/ 3) * 3;
            int bCol = (col ~/ 3) * 3;
            for (int i = 0; i < 3; i++) {
              for (int j = 0; j < 3; j++) {
                candidates[bRow + i][bCol + j].remove(num);
              }
            }
            candidates[row][col].clear();
            progress = true;
          }
        }
      }
      if (progress) continue;
      // 3. X-Wing (rows)
      for (int num = 1; num <= 9; num++) {
        List<List<int>> rowsWithTwo = [];
        for (int row = 0; row < 9; row++) {
          List<int> cols = [];
          for (int col = 0; col < 9; col++) {
            if (board[row][col] == 0 && candidates[row][col].contains(num)) {
              cols.add(col);
            }
          }
          if (cols.length == 2) {
            rowsWithTwo.add([row, cols[0], cols[1]]);
          }
        }
        for (int i = 0; i < rowsWithTwo.length; i++) {
          for (int j = i + 1; j < rowsWithTwo.length; j++) {
            if (rowsWithTwo[i][1] == rowsWithTwo[j][1] && rowsWithTwo[i][2] == rowsWithTwo[j][2]) {
              // X-Wing found in columns rowsWithTwo[i][1] and [2], rows i and j
              bool eliminated = false;
              for (int row = 0; row < 9; row++) {
                if (row != rowsWithTwo[i][0] && row != rowsWithTwo[j][0]) {
                  if (candidates[row][rowsWithTwo[i][1]].remove(num)) eliminated = true;
                  if (candidates[row][rowsWithTwo[i][2]].remove(num)) eliminated = true;
                }
              }
              if (eliminated) {
                techniques.add('X-Wing');
                progress = true;
              }
            }
          }
        }
      }
      // 4. X-Wing (columns)
      for (int num = 1; num <= 9; num++) {
        List<List<int>> colsWithTwo = [];
        for (int col = 0; col < 9; col++) {
          List<int> rows = [];
          for (int row = 0; row < 9; row++) {
            if (board[row][col] == 0 && candidates[row][col].contains(num)) {
              rows.add(row);
            }
          }
          if (rows.length == 2) {
            colsWithTwo.add([col, rows[0], rows[1]]);
          }
        }
        for (int i = 0; i < colsWithTwo.length; i++) {
          for (int j = i + 1; j < colsWithTwo.length; j++) {
            if (colsWithTwo[i][1] == colsWithTwo[j][1] && colsWithTwo[i][2] == colsWithTwo[j][2]) {
              // X-Wing found in rows colsWithTwo[i][1] and [2], cols i and j
              bool eliminated = false;
              for (int col = 0; col < 9; col++) {
                if (col != colsWithTwo[i][0] && col != colsWithTwo[j][0]) {
                  if (candidates[colsWithTwo[i][1]][col].remove(num)) eliminated = true;
                  if (candidates[colsWithTwo[i][2]][col].remove(num)) eliminated = true;
                }
              }
              if (eliminated) {
                techniques.add('X-Wing');
                progress = true;
              }
            }
          }
        }
      }
      // 5. XY-Wing
      // For each cell with exactly 2 candidates, try to find XY-Wing pattern
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (board[row][col] == 0 && candidates[row][col].length == 2) {
            var xy = candidates[row][col].toList();
            // Find a cell sharing a unit with (row,col) with candidates [x,z]
            for (int r2 = 0; r2 < 9; r2++) {
              for (int c2 = 0; c2 < 9; c2++) {
                if ((r2 == row && c2 == col) || board[r2][c2] != 0) continue;
                if (candidates[r2][c2].length == 2) {
                  var xz = candidates[r2][c2].toList();
                  // Must share one candidate with (row,col)
                  var shared = xy.where((v) => xz.contains(v)).toList();
                  if (shared.length != 1) continue;
                  int x = shared[0];
                  int y = xy.firstWhere((v) => v != x);
                  int z = xz.firstWhere((v) => v != x);
                  // Find a third cell sharing a unit with both, with candidates [y,z]
                  for (int r3 = 0; r3 < 9; r3++) {
                    for (int c3 = 0; c3 < 9; c3++) {
                      if ((r3 == row && c3 == col) || (r3 == r2 && c3 == c2) || board[r3][c3] != 0) continue;
                      if (candidates[r3][c3].length == 2) {
                        var yz = candidates[r3][c3].toList();
                        if (yz.contains(y) && yz.contains(z) && !yz.contains(x)) {
                          // All three cells must see each other (share a unit)
                          bool sharesUnit1 = (r3 == row || c3 == col || (r3 ~/ 3 == row ~/ 3 && c3 ~/ 3 == col ~/ 3));
                          bool sharesUnit2 = (r3 == r2 || c3 == c2 || (r3 ~/ 3 == r2 ~/ 3 && c3 ~/ 3 == c2 ~/ 3));
                          if (sharesUnit1 && sharesUnit2) {
                            // Eliminate z from all cells that see both (row,col) and (r2,c2)
                            bool eliminated = false;
                            for (int r = 0; r < 9; r++) {
                              for (int c = 0; c < 9; c++) {
                                if ((r == row && c == col) || (r == r2 && c == c2) || (r == r3 && c == c3)) continue;
                                if (board[r][c] == 0 && candidates[r][c].contains(z)) {
                                  bool sees1 = (r == row || c == col || (r ~/ 3 == row ~/ 3 && c ~/ 3 == col ~/ 3));
                                  bool sees2 = (r == r2 || c == c2 || (r ~/ 3 == r2 ~/ 3 && c ~/ 3 == c2 ~/ 3));
                                  if (sees1 && sees2) {
                                    candidates[r][c].remove(z);
                                    eliminated = true;
                                  }
                                }
                              }
                            }
                            if (eliminated) {
                              techniques.add('XY-Wing');
                              progress = true;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      // 6. Swordfish (rows)
      for (int num = 1; num <= 9; num++) {
        List<List<int>> rowsWithTwoOrThree = [];
        for (int row = 0; row < 9; row++) {
          List<int> cols = [];
          for (int col = 0; col < 9; col++) {
            if (board[row][col] == 0 && candidates[row][col].contains(num)) {
              cols.add(col);
            }
          }
          if (cols.length == 2 || cols.length == 3) {
            rowsWithTwoOrThree.add([row, ...cols]);
          }
        }
        for (int i = 0; i < rowsWithTwoOrThree.length; i++) {
          for (int j = i + 1; j < rowsWithTwoOrThree.length; j++) {
            for (int k = j + 1; k < rowsWithTwoOrThree.length; k++) {
              Set<int> allCols = {
                ...rowsWithTwoOrThree[i].sublist(1),
                ...rowsWithTwoOrThree[j].sublist(1),
                ...rowsWithTwoOrThree[k].sublist(1),
              };
              if (allCols.length == 3) {
                // Swordfish found in these 3 rows and 3 columns
                bool eliminated = false;
                for (int row = 0; row < 9; row++) {
                  if (row != rowsWithTwoOrThree[i][0] && row != rowsWithTwoOrThree[j][0] && row != rowsWithTwoOrThree[k][0]) {
                    for (int col in allCols) {
                      if (candidates[row][col].remove(num)) eliminated = true;
                    }
                  }
                }
                if (eliminated) {
                  techniques.add('Swordfish');
                  progress = true;
                }
              }
            }
          }
        }
      }
      // 7. Swordfish (columns)
      for (int num = 1; num <= 9; num++) {
        List<List<int>> colsWithTwoOrThree = [];
        for (int col = 0; col < 9; col++) {
          List<int> rows = [];
          for (int row = 0; row < 9; row++) {
            if (board[row][col] == 0 && candidates[row][col].contains(num)) {
              rows.add(row);
            }
          }
          if (rows.length == 2 || rows.length == 3) {
            colsWithTwoOrThree.add([col, ...rows]);
          }
        }
        for (int i = 0; i < colsWithTwoOrThree.length; i++) {
          for (int j = i + 1; j < colsWithTwoOrThree.length; j++) {
            for (int k = j + 1; k < colsWithTwoOrThree.length; k++) {
              Set<int> allRows = {
                ...colsWithTwoOrThree[i].sublist(1),
                ...colsWithTwoOrThree[j].sublist(1),
                ...colsWithTwoOrThree[k].sublist(1),
              };
              if (allRows.length == 3) {
                // Swordfish found in these 3 columns and 3 rows
                bool eliminated = false;
                for (int col = 0; col < 9; col++) {
                  if (col != colsWithTwoOrThree[i][0] && col != colsWithTwoOrThree[j][0] && col != colsWithTwoOrThree[k][0]) {
                    for (int row in allRows) {
                      if (candidates[row][col].remove(num)) eliminated = true;
                    }
                  }
                }
                if (eliminated) {
                  techniques.add('Swordfish');
                  progress = true;
                }
              }
            }
          }
        }
      }
      // 8. Simple Coloring (single candidate, two-coloring)
      for (int num = 1; num <= 9; num++) {
        // Build graph: each cell with candidate num is a node, edges if they see each other
        List<List<int>> cells = [];
        for (int row = 0; row < 9; row++) {
          for (int col = 0; col < 9; col++) {
            if (board[row][col] == 0 && candidates[row][col].contains(num)) {
              cells.add([row, col]);
            }
          }
        }
        // Only try if at least 4 cells
        if (cells.length < 4) continue;
        // Try to color the graph (two colors)
        Map<String, int> color = {};
        bool colored = false;
        void dfs(int idx, int c) {
          String key = '${cells[idx][0]},${cells[idx][1]}';
          if (color.containsKey(key)) return;
          color[key] = c;
          for (int j = 0; j < cells.length; j++) {
            if (j == idx) continue;
            if (_cellsSeeEachOther(cells[idx], cells[j])) {
              dfs(j, 1 - c);
            }
          }
        }
        dfs(0, 0);
        if (color.length < cells.length) continue; // not fully colored
        // If any two cells of the same color see each other, eliminate num from all cells of that color
        for (int i = 0; i < cells.length; i++) {
          for (int j = i + 1; j < cells.length; j++) {
            if (color['${cells[i][0]},${cells[i][1]}'] ==
                color['${cells[j][0]},${cells[j][1]}'] &&
                _cellsSeeEachOther(cells[i], cells[j])) {
              // Eliminate num from all cells of this color
              int badColor = color['${cells[i][0]},${cells[i][1]}'] ?? 0;
              bool eliminated = false;
              for (int k = 0; k < cells.length; k++) {
                if (color['${cells[k][0]},${cells[k][1]}'] == badColor) {
                  if (candidates[cells[k][0]][cells[k][1]].remove(num)) eliminated = true;
                }
              }
              if (eliminated) {
                techniques.add('Coloring');
                progress = true;
              }
            }
          }
        }
      }
      // 9. Unique Rectangle (Type 1)
      // Look for four cells forming a rectangle with the same two candidates, and one cell with an extra candidate
      for (int num1 = 1; num1 <= 9; num1++) {
        for (int num2 = num1 + 1; num2 <= 9; num2++) {
          // For each box pair
          for (int boxRow = 0; boxRow < 3; boxRow++) {
            for (int boxCol = 0; boxCol < 3; boxCol++) {
              // Collect all cells in this box with exactly 2 or 3 candidates including num1 and num2
              List<List<int>> cells = [];
              for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                  int row = boxRow * 3 + i;
                  int col = boxCol * 3 + j;
                  if (board[row][col] == 0 && candidates[row][col].contains(num1) && candidates[row][col].contains(num2) && (candidates[row][col].length == 2 || candidates[row][col].length == 3)) {
                    cells.add([row, col]);
                  }
                }
              }
              if (cells.length < 2) continue;
              // Try all pairs of these cells
              for (int i = 0; i < cells.length; i++) {
                for (int j = i + 1; j < cells.length; j++) {
                  int row1 = cells[i][0], col1 = cells[i][1];
                  int row2 = cells[j][0], col2 = cells[j][1];
                  // Find the rectangle corners
                  int row3 = row1, col3 = col2;
                  int row4 = row2, col4 = col1;
                  if (row3 == row4 && col3 == col4) continue;
                  // All four corners must be empty and have num1 and num2 as candidates
                  List<List<int>> rect = [[row1, col1], [row2, col2], [row3, col3], [row4, col4]];
                  bool valid = true;
                  for (var cell in rect) {
                    if (board[cell[0]][cell[1]] != 0) valid = false;
                    if (!candidates[cell[0]][cell[1]].contains(num1) || !candidates[cell[0]][cell[1]].contains(num2)) valid = false;
                  }
                  if (!valid) continue;
                  // If one of the corners has a third candidate, eliminate it
                  for (var cell in rect) {
                    if (candidates[cell[0]][cell[1]].length == 3) {
                      Set<int> extra = Set.from(candidates[cell[0]][cell[1]]);
                      extra.remove(num1);
                      extra.remove(num2);
                      if (extra.isNotEmpty) {
                        bool eliminated = false;
                        for (int ex in extra) {
                          if (candidates[cell[0]][cell[1]].remove(ex)) eliminated = true;
                        }
                        if (eliminated) {
                          techniques.add('Unique Rectangle');
                          progress = true;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return techniques;
  }

  // Helper for coloring: do two cells see each other?
  static bool _cellsSeeEachOther(List<int> a, List<int> b) {
    return a[0] == b[0] || a[1] == b[1] || (a[0] ~/ 3 == b[0] ~/ 3 && a[1] ~/ 3 == b[1] ~/ 3);
  }

  // Categorize techniques
  static Set<String> getMasterTechniques(Set<String> techniques) {
    return techniques.where((t) => t == 'Unique Rectangle' || t == 'X-Wing' || t == 'XY-Wing').toSet();
  }

  static Set<String> getEvilTechniques(Set<String> techniques) {
    return techniques.where((t) => t == 'Coloring' || t == 'Swordfish').toSet();
  }
} 