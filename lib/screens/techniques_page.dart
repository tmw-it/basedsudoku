import 'package:flutter/material.dart';
import 'package:based_sudoku/models/sudoku_game.dart';

class Technique {
  final String name;
  final String description;
  final String example;
  final List<Difficulty> relevantDifficulties;
  final List<List<int>>? boardExample;
  final List<List<int>>? highlightCells;
  final Map<List<int>, List<int>>? candidates; // cell -> candidates
  final List<int>? solutionCell; // [row, col]
  final List<int>? highlightRow;
  final List<int>? highlightCol;
  final List<int>? highlightBox;
  // (arrows, circles, etc. can be added as needed)

  Technique({
    required this.name,
    required this.description,
    required this.example,
    required this.relevantDifficulties,
    this.boardExample,
    this.highlightCells,
    this.candidates,
    this.solutionCell,
    this.highlightRow,
    this.highlightCol,
    this.highlightBox,
  });
}

final List<Technique> techniques = [
  Technique(
    name: 'Naked Single',
    description: 'A cell where only one number can be placed because all other numbers (1-9) are already present in its row, column, or 3x3 box. This is the most basic technique and often the first step in solving a puzzle. When you find a naked single, you can confidently place that number in the cell.',
    example: 'The green cell is the naked single. The yellow cells are filled 5s that eliminate 5 as a candidate in the green cell.',
    relevantDifficulties: [Difficulty.easy],
  ),
  Technique(
    name: 'Hidden Single',
    description: 'A number that can only be placed in one cell within a row, column, or 3x3 box, even though that cell might have other candidates. This occurs when all other cells in the unit cannot contain that number due to existing numbers or other constraints. Finding hidden singles is crucial for solving puzzles as they provide definite placements.',
    example: 'Only the green cell in row 5 can be 7. The yellow cells are filled numbers that block other cells in the row from being 7.',
    relevantDifficulties: [Difficulty.easy],
  ),
  Technique(
    name: 'Locked Candidates',
    description: 'A pattern where a candidate is confined to a single row or column within a 3x3 box, or vice versa. When this happens, that candidate can be eliminated from other cells in that row/column outside the box. This technique creates a "line of influence" that extends beyond the box boundaries.',
    example: 'All 2s in the top-left box are in row 2. So, 2 can be eliminated from other cells in row 2 outside the box.',
    relevantDifficulties: [Difficulty.medium],
  ),
  Technique(
    name: 'Naked Pair/Triple',
    description: 'When two or three cells in a unit (row, column, or box) contain only the same two or three candidates, those candidates can be removed from other cells in that unit. This is because those numbers must go in those specific cells, making them unavailable elsewhere in the unit. This technique is powerful for eliminating candidates and often leads to finding hidden singles.',
    example: 'Cells (3, 3) and (3, 6) are the only ones in row 4 with [3,8] as candidates. Remove 3 and 8 from other cells in row 4.',
    relevantDifficulties: [Difficulty.medium],
  ),
  Technique(
    name: 'Hidden Pair/Triple',
    description: 'When two or three candidates only appear in two or three cells within a unit, those cells must contain those candidates. This means other candidates in those cells can be eliminated. This is like finding a "secret relationship" between numbers that isn\'t immediately obvious. Hidden pairs/triples often lead to finding naked singles in other cells.',
    example: 'In row 5, only cells (4, 2) and (4, 5) can be 4 or 9. These cells must be [4,9].',
    relevantDifficulties: [Difficulty.hard],
  ),
  Technique(
    name: 'X-Wing',
    description: 'A pattern where a candidate appears in exactly two cells in two different rows, and these cells form a rectangle (same columns). This means the candidate must be in one of two positions in each row, creating a strong constraint. As a result, that candidate can be eliminated from other cells in those columns. This is a powerful technique that can solve multiple cells at once.',
    example: 'In this example, 5 is a candidate in exactly two cells in rows 2 and 7, and those columns match. Remove 5 from those columns elsewhere.',
    relevantDifficulties: [Difficulty.master],
  ),
  Technique(
    name: 'Swordfish',
    description: 'An extension of the X-Wing pattern to three rows and columns. When a candidate appears in exactly three cells in each of three different rows, and these cells align in three columns, that candidate can be eliminated from other cells in those columns. This is like an X-Wing with an extra row/column, creating an even stronger constraint.',
    example: 'In this example, 6 is a candidate in three cells in three rows and columns, forming a swordfish pattern.',
    relevantDifficulties: [Difficulty.evil],
  ),
  Technique(
    name: 'XY-Wing',
    description: 'A three-cell pattern that creates a chain of eliminations. The "pivot" cell has two candidates (XY), and it can see two other cells with candidates (XZ and YZ). Any cell that can see all three cells cannot contain Z. This is because either the pivot must be X (making the second cell Z) or the pivot must be Y (making the third cell Z). This technique is powerful for eliminating candidates in complex situations.',
    example: 'Cells (2,2), (2,4), and (4,2) form an XY-Wing. If A is [2,3], B is [3,5], C is [2,5], and all see each other, eliminate 5 from cells that see both A and C.',
    relevantDifficulties: [Difficulty.master],
  ),
  Technique(
    name: 'Coloring',
    description: 'A technique that uses colors to track candidate chains and eliminate possibilities. When a candidate appears in exactly two cells in a unit, one must be true and one must be false. By assigning colors to these cells and following the chains of connected cells, you can identify cells where the candidate must be true or false. This is particularly useful for solving puzzles that require advanced techniques.',
    example: 'If two chains of 7s connect, one color must be true, so eliminate 7s that see both.',
    relevantDifficulties: [Difficulty.evil],
  ),
  Technique(
    name: 'Unique Rectangle',
    description: 'A pattern that would allow multiple solutions if certain candidates weren\'t eliminated. When four cells form a rectangle and only two candidates are present in each cell, one of the cells must contain a different number to maintain the puzzle\'s uniqueness. This technique relies on the fact that a valid Sudoku puzzle must have exactly one solution. It\'s particularly useful in very difficult puzzles where other techniques have been exhausted.',
    example: 'If four cells form a rectangle and only two candidates are present, eliminate those candidates from other cells.',
    relevantDifficulties: [Difficulty.master],
  ),
];

class StaticSudokuBoard extends StatelessWidget {
  final List<List<int>> board;
  final List<List<int>>? highlightCells;
  final Map<List<int>, List<int>>? candidates;
  final List<int>? solutionCell;
  final List<int>? highlightRow;
  final List<int>? highlightCol;
  final List<int>? highlightBox;
  const StaticSudokuBoard({
    super.key,
    required this.board,
    this.highlightCells,
    this.candidates,
    this.solutionCell,
    this.highlightRow,
    this.highlightCol,
    this.highlightBox,
  });

  @override
  Widget build(BuildContext context) {
    const cellSize = 28.0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!, width: 2),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(9, (row) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(9, (col) {
            final isHighlighted = highlightCells?.any((c) => c[0] == row && c[1] == col) ?? false;
            final isSolution = solutionCell != null && solutionCell![0] == row && solutionCell![1] == col;
            final isRow = highlightRow != null && highlightRow!.contains(row);
            final isCol = highlightCol != null && highlightCol!.contains(col);
            final isBox = highlightBox != null &&
                (row ~/ 3 == highlightBox![0] && col ~/ 3 == highlightBox![1]);
            final cellCandidates = candidates?.entries.firstWhere(
              (e) => e.key[0] == row && e.key[1] == col,
              orElse: () => const MapEntry(<int>[], <int>[]),
            ).value;
            return Container(
              width: cellSize,
              height: cellSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSolution
                    ? Colors.green[200]
                    : isHighlighted
                        ? Colors.yellow[200]
                        : isRow || isCol || isBox
                            ? Colors.blue[50]
                            : Colors.transparent,
                border: Border(
                  top: BorderSide(width: row % 3 == 0 ? 2 : 0.5, color: Colors.grey[400]!),
                  left: BorderSide(width: col % 3 == 0 ? 2 : 0.5, color: Colors.grey[400]!),
                  right: BorderSide(width: col == 8 ? 2 : 0.5, color: Colors.grey[400]!),
                  bottom: BorderSide(width: row == 8 ? 2 : 0.5, color: Colors.grey[400]!),
                ),
              ),
              child: board[row][col] != 0
                  ? Text(
                      board[row][col].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  : (cellCandidates != null && cellCandidates.isNotEmpty)
                      ? Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 1,
                          runSpacing: 1,
                          children: List.generate(9, (i) {
                            final n = i + 1;
                            final isMain = isSolution && cellCandidates.length == 1 && cellCandidates[0] == n;
                            final isCandidate = cellCandidates.contains(n);
                            return SizedBox(
                              width: 8,
                              height: 12,
                              child: Center(
                                child: Text(
                                  isCandidate ? n.toString() : '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                                    color: isMain
                                        ? Colors.green[900]
                                        : isCandidate
                                            ? Colors.black
                                            : Colors.grey[300],
                                  ),
                                ),
                              ),
                            );
                          }),
                        )
                      : const SizedBox.shrink(),
            );
          }),
        )),
      ),
    );
  }
}

class TechniqueDetailPage extends StatelessWidget {
  final Technique technique;
  const TechniqueDetailPage({super.key, required this.technique});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(technique.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(technique.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              children: technique.relevantDifficulties.map((d) => Chip(
                label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                backgroundColor: difficultyColor(d),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text(technique.description, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class TechniquesPage extends StatelessWidget {
  const TechniquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sortedTechniques = [...techniques]
      ..sort((a, b) {
        // Get the lowest difficulty for each technique
        final aDiff = a.relevantDifficulties.first;
        final bDiff = b.relevantDifficulties.first;
        
        // Compare difficulties first
        final diffCompare = aDiff.index.compareTo(bDiff.index);
        if (diffCompare != 0) return diffCompare;
        
        // If same difficulty, sort alphabetically
        return a.name.compareTo(b.name);
      });
    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku Techniques')),
      body: ListView.builder(
        itemCount: sortedTechniques.length,
        itemBuilder: (context, index) {
          final tech = sortedTechniques[index];
          return ListTile(
            title: Text(tech.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: tech.relevantDifficulties.map((d) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Chip(
                  label: Text(d.name[0].toUpperCase() + d.name.substring(1), style: const TextStyle(fontSize: 10)),
                  backgroundColor: difficultyColor(d),
                ),
              )).toList(),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TechniqueDetailPage(technique: tech),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Color difficultyColor(Difficulty d) {
  switch (d) {
    case Difficulty.easy:
      return const Color(0xFFDDEEFF); // light blue
    case Difficulty.medium:
      return const Color(0xFFDFF5E3); // light green
    case Difficulty.hard:
      return const Color(0xFFFFFDE7); // light yellow
    case Difficulty.master:
      return const Color(0xFFFFF3E0); // light orange
    case Difficulty.evil:
      return const Color(0xFFFFEBEE); // light red
  }
} 