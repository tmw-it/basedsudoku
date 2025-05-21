import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum Difficulty { easy, medium, hard, master, evil }

class SudokuGame extends ChangeNotifier {
  final String id;
  final Difficulty difficulty;
  final List<List<int>> solution;
  final List<List<int>> puzzle;
  final List<List<Set<int>>> notes;
  final List<List<bool>> isFixed;
  Duration timeElapsed;
  bool isPaused;
  bool isCompleted;
  final List<Move> moveHistory = [];
  final List<Move> redoHistory = [];
  int? selectedRow;
  int? selectedCol;

  SudokuGame({
    String? id,
    required this.difficulty,
    required this.solution,
    required this.puzzle,
    List<List<Set<int>>>? notes,
    List<List<bool>>? isFixed,
    this.timeElapsed = Duration.zero,
    this.isPaused = false,
    this.isCompleted = false,
  })  : id = id ?? const Uuid().v4(),
        notes = notes ?? List.generate(9, (_) => List.generate(9, (_) => {})),
        isFixed = isFixed ?? List.generate(9, (i) => List.generate(9, (j) => puzzle[i][j] != 0));

  SudokuGame copyWith({
    String? id,
    Difficulty? difficulty,
    List<List<int>>? solution,
    List<List<int>>? puzzle,
    List<List<Set<int>>>? notes,
    List<List<bool>>? isFixed,
    Duration? timeElapsed,
    bool? isPaused,
    bool? isCompleted,
  }) {
    return SudokuGame(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      solution: solution ?? this.solution,
      puzzle: puzzle ?? this.puzzle,
      notes: notes ?? this.notes,
      isFixed: isFixed ?? this.isFixed,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool isValidMove(int row, int col, int value) {
    if (value == 0) return true;
    
    // Check row
    for (int i = 0; i < 9; i++) {
      if (i != col && puzzle[row][i] == value) return false;
    }
    
    // Check column
    for (int i = 0; i < 9; i++) {
      if (i != row && puzzle[i][col] == value) return false;
    }
    
    // Check 3x3 box
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (boxRow + i != row && boxCol + j != col && 
            puzzle[boxRow + i][boxCol + j] == value) {
          return false;
        }
      }
    }
    
    return true;
  }

  void toggleNote(int row, int col, int value) {
    if (isFixed[row][col]) return;
    
    if (notes[row][col].contains(value)) {
      notes[row][col].remove(value);
    } else {
      notes[row][col].add(value);
    }
    notifyListeners();
  }

  void setValue(int row, int col, int value) {
    if (isFixed[row][col]) return;
    final previousValue = puzzle[row][col];
    final previousNotes = Set<int>.from(notes[row][col]);
    puzzle[row][col] = value;
    notes[row][col].clear();
    // Remove notes from affected cells
    for (int i = 0; i < 9; i++) {
      if (i != col) notes[row][i].remove(value);
      if (i != row) notes[i][col].remove(value);
    }
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (boxRow + i != row && boxCol + j != col) {
          notes[boxRow + i][boxCol + j].remove(value);
        }
      }
    }
    if (checkCompletion()) {
      isCompleted = true;
      print('Puzzle completed! isCompleted set to true');
    }
    moveHistory.add(Move(
      row: row,
      col: col,
      previousValue: previousValue,
      newValue: value,
      previousNotes: previousNotes,
      newNotes: Set<int>.from(notes[row][col]),
      isNote: false,
    ));
    redoHistory.clear();
    notifyListeners();
  }

  void clearCell(int row, int col) {
    if (isFixed[row][col]) return;
    final previousValue = puzzle[row][col];
    final previousNotes = Set<int>.from(notes[row][col]);
    puzzle[row][col] = 0;
    // Restore notes if the last move for this cell had previousNotes
    Move? last = moveHistory.isNotEmpty ? moveHistory.last : null;
    if (last != null && last.row == row && last.col == col && last.previousNotes != null) {
      notes[row][col] = Set<int>.from(last.previousNotes!);
    }
    moveHistory.add(Move(
      row: row,
      col: col,
      previousValue: previousValue,
      newValue: 0,
      previousNotes: previousNotes,
      newNotes: Set<int>.from(notes[row][col]),
      isNote: false,
    ));
    redoHistory.clear();
    notifyListeners();
  }

  bool checkCompletion() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (puzzle[i][j] != solution[i][j]) {
          print('Mismatch at ($i, $j): puzzle=${puzzle[i][j]}, solution=${solution[i][j]}');
        }
        if (puzzle[i][j] != solution[i][j]) return false;
      }
    }
    return true;
  }

  void update(SudokuGame newGame) {
    puzzle.clear();
    puzzle.addAll(newGame.puzzle);
    notes.clear();
    notes.addAll(newGame.notes);
    notifyListeners();
  }

  void setPaused(bool paused) {
    if (isPaused != paused) {
      isPaused = paused;
      notifyListeners();
    }
  }

  void setTimeElapsed(Duration d) {
    timeElapsed = d;
    notifyListeners();
  }

  bool canUndo() => moveHistory.isNotEmpty;
  bool canRedo() => redoHistory.isNotEmpty;

  void setSelectedCell(int? row, int? col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void undo() {
    if (!canUndo()) return;
    final lastMove = moveHistory.removeLast();
    redoHistory.add(lastMove);
    // Restore the previous state
    if (lastMove.isNote) {
      notes[lastMove.row][lastMove.col] = lastMove.previousNotes ?? {};
    } else {
      puzzle[lastMove.row][lastMove.col] = lastMove.previousValue ?? 0;
      notes[lastMove.row][lastMove.col] = lastMove.previousNotes ?? {};
    }
    setSelectedCell(lastMove.row, lastMove.col);
    notifyListeners();
  }

  void redo() {
    if (!canRedo()) return;
    final move = redoHistory.removeLast();
    moveHistory.add(move);
    // Apply the move again
    if (move.isNote) {
      notes[move.row][move.col] = move.newNotes ?? {};
    } else {
      puzzle[move.row][move.col] = move.newValue ?? 0;
      notes[move.row][move.col] = move.newNotes ?? {};
    }
    setSelectedCell(move.row, move.col);
    notifyListeners();
  }

  void makeMove(int row, int col, int value) {
    if (isFixed[row][col]) return;
    
    final previousValue = puzzle[row][col];
    puzzle[row][col] = value;
    
    // Clear redo history when a new move is made
    redoHistory.clear();
    
    // Add move to history
    moveHistory.add(Move(
      row: row,
      col: col,
      previousValue: previousValue,
      newValue: value,
      isNote: false,
    ));
    notifyListeners();
  }

  void updateNotes(int row, int col, Set<int> newNotes) {
    if (isFixed[row][col]) return;
    
    final previousNotes = Set<int>.from(notes[row][col]);
    notes[row][col] = newNotes;
    
    // Clear redo history when a new move is made
    redoHistory.clear();
    
    // Add move to history
    moveHistory.add(Move(
      row: row,
      col: col,
      previousNotes: previousNotes,
      newNotes: newNotes,
      isNote: true,
    ));
    notifyListeners();
  }

  // Add method to get the last move's position
  (int, int)? getLastMovePosition() {
    if (moveHistory.isEmpty) return null;
    final lastMove = moveHistory.last;
    return (lastMove.row, lastMove.col);
  }

  // Add method to get the next redo move's position
  (int, int)? getNextRedoPosition() {
    if (redoHistory.isEmpty) return null;
    final nextMove = redoHistory.last;
    return (nextMove.row, nextMove.col);
  }

  void setCompleted(bool value) {
    isCompleted = value;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'difficulty': difficulty.name,
      'solution': solution,
      'puzzle': puzzle,
      'notes': notes.map((row) => row.map((cell) => cell.toList()).toList()).toList(),
      'isFixed': isFixed,
      'timeElapsed': timeElapsed.inSeconds,
      'isPaused': isPaused,
      'isCompleted': isCompleted,
      'moveHistory': moveHistory.map((m) => m.toJson()).toList(),
      'redoHistory': redoHistory.map((m) => m.toJson()).toList(),
      'selectedRow': selectedRow,
      'selectedCol': selectedCol,
    };
  }

  static SudokuGame? fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['id'] == null || json['difficulty'] == null || json['solution'] == null || json['puzzle'] == null || json['notes'] == null || json['isFixed'] == null) {
      return null;
    }
    try {
      return SudokuGame(
        id: json['id'],
        difficulty: Difficulty.values.firstWhere((d) => d.name == json['difficulty']),
        solution: List<List<int>>.from((json['solution'] as List).map((row) => List<int>.from(row))),
        puzzle: List<List<int>>.from((json['puzzle'] as List).map((row) => List<int>.from(row))),
        notes: List<List<Set<int>>>.from((json['notes'] as List).map((row) => List<Set<int>>.from((row as List).map((cell) => Set<int>.from(cell))))),
        isFixed: List<List<bool>>.from((json['isFixed'] as List).map((row) => List<bool>.from(row))),
        timeElapsed: Duration(seconds: json['timeElapsed'] ?? 0),
        isPaused: json['isPaused'] ?? false,
        isCompleted: json['isCompleted'] ?? false,
      )
        ..moveHistory.addAll((json['moveHistory'] as List? ?? []).map((m) => Move.fromJson(m)))
        ..redoHistory.addAll((json['redoHistory'] as List? ?? []).map((m) => Move.fromJson(m)))
        ..selectedRow = json['selectedRow']
        ..selectedCol = json['selectedCol'];
    } catch (e) {
      return null;
    }
  }
}

class Move {
  final int row;
  final int col;
  final int? previousValue;
  final int? newValue;
  final Set<int>? previousNotes;
  final Set<int>? newNotes;
  final bool isNote;

  Move({
    required this.row,
    required this.col,
    this.previousValue,
    this.newValue,
    this.previousNotes,
    this.newNotes,
    required this.isNote,
  });

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'previousValue': previousValue,
    'newValue': newValue,
    'previousNotes': previousNotes?.toList(),
    'newNotes': newNotes?.toList(),
    'isNote': isNote,
  };

  static Move fromJson(Map<String, dynamic> json) => Move(
    row: json['row'],
    col: json['col'],
    previousValue: json['previousValue'],
    newValue: json['newValue'],
    previousNotes: json['previousNotes'] != null ? Set<int>.from(json['previousNotes']) : null,
    newNotes: json['newNotes'] != null ? Set<int>.from(json['newNotes']) : null,
    isNote: json['isNote'],
  );
} 