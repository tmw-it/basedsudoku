// Remove Flutter dependency
enum Difficulty { easy, medium, hard, master, evil }

class TechniqueExample {
  final List<List<int>> board;
  final List<List<int>> highlightCells;
  final List<int> solutionCell;
  final Map<List<int>, List<int>>? candidates;

  TechniqueExample({
    required this.board,
    required this.highlightCells,
    required this.solutionCell,
    this.candidates,
  });
}

class TechniqueExampleGenerator {
  /// Generates a Naked Single example
  static TechniqueExample generateNakedSingle() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place numbers that eliminate all candidates except one in the target cell
    // Example: Place 5s in the same row, column, and box to make a cell a naked single for 5
    board[6][4] = 5; // 5 in the same column
    board[7][0] = 5; // 5 in the same row
    board[8][8] = 5; // 5 in the same box
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [7, 4], // the naked single
        [6, 4], // 5 in the same column
        [7, 0], // 5 in the same row
        [8, 8], // 5 in the same box
      ],
      solutionCell: [7, 4],
    );
  }

  /// Generates a Hidden Single example
  static TechniqueExample generateHiddenSingle() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Fill row 4 with numbers 1-9 (except 7) to make cell (4,4) a hidden single for 7
    board[4] = [1, 2, 3, 4, 0, 5, 6, 8, 9];
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [4, 4], // the hidden single
        [4, 0], [4, 1], [4, 2], [4, 3], [4, 5], [4, 6], [4, 7], [4, 8], // blocking cells
      ],
      solutionCell: [4, 4],
    );
  }

  /// Generates a Locked Candidates example
  static TechniqueExample generateLockedCandidates() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place 2s in the top-left box that are confined to row 2
    board[0][0] = 2;
    board[1][1] = 2;
    board[2][2] = 2;
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [0, 0], [1, 1], [2, 2], // 2s in the box
        [1, 4], // cell in row 2 outside the box
      ],
      solutionCell: [1, 4],
    );
  }

  /// Generates a Naked Pair example
  static TechniqueExample generateNakedPair() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place a naked pair in row 3
    board[3][3] = 3;
    board[3][6] = 8;
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [3, 3], [3, 6], // the naked pair
      ],
      solutionCell: [3, 3],
    );
  }

  /// Generates a Hidden Pair example
  static TechniqueExample generateHiddenPair() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place a hidden pair in row 4
    board[4][2] = 4;
    board[4][5] = 9;
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [4, 2], [4, 5], // the hidden pair
      ],
      solutionCell: [4, 2],
    );
  }

  /// Generates an X-Wing example
  static TechniqueExample generateXWing() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place 5s in an X-Wing pattern
    board[1][4] = 5;
    board[1][8] = 5;
    board[6][4] = 5;
    board[6][8] = 5;
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [1, 4], [1, 8], [6, 4], [6, 8], // the X-Wing
      ],
      solutionCell: [1, 4],
    );
  }

  /// Generates a Swordfish example
  static TechniqueExample generateSwordfish() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place 6s in a Swordfish pattern
    board[0][4] = 6;
    board[0][8] = 6;
    board[2][4] = 6;
    board[2][8] = 6;
    board[4][4] = 6;
    board[4][8] = 6;
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [0, 4], [0, 8], [2, 4], [2, 8], [4, 4], [4, 8], // the Swordfish
      ],
      solutionCell: [0, 4],
    );
  }

  /// Generates an XY-Wing example
  static TechniqueExample generateXYWing() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place the XY-Wing pattern
    board[2][2] = 2;
    board[2][4] = 3;
    board[4][2] = 5;
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [2, 2], [2, 4], [4, 2], // the XY-Wing
      ],
      solutionCell: [2, 2],
    );
  }

  /// Generates a Unique Rectangle example
  static TechniqueExample generateUniqueRectangle() {
    // Create an empty board
    final board = List.generate(9, (_) => List.filled(9, 0));
    
    // Place the Unique Rectangle pattern
    board[2][2] = 1;
    board[2][4] = 2;
    board[4][2] = 2;
    board[4][4] = 1;
    
    return TechniqueExample(
      board: board,
      highlightCells: [
        [2, 2], [2, 4], [4, 2], [4, 4], // the Unique Rectangle
      ],
      solutionCell: [2, 2],
    );
  }

  /// Prints the example in a format that can be pasted into techniques_page.dart
  static void printExample(TechniqueExample example) {
    print('boardExample: [');
    for (var row in example.board) {
      print('  ${row.toString()},');
    }
    print('],');
    print('highlightCells: [');
    for (var cell in example.highlightCells) {
      print('  ${cell.toString()},');
    }
    print('],');
    print('solutionCell: ${example.solutionCell},');
    if (example.candidates != null) {
      print('candidates: {');
      example.candidates!.forEach((cell, candidates) {
        print('  ${cell.toString()}: ${candidates.toString()},');
      });
      print('},');
    }
  }
} 