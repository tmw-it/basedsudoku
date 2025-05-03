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
            puzzle[boxRow + i][boxCol + j] == value) return false;
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
    
    // Check for completion
    if (checkCompletion()) {
      isCompleted = true;
      print('Puzzle completed! isCompleted set to true');
    }
    notifyListeners();
  }

  void clearCell(int row, int col) {
    if (isFixed[row][col]) return;
    puzzle[row][col] = 0;
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
} 