import 'package:flutter/material.dart';
import 'package:sudoku/models/sudoku_game.dart';

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
    description: 'A cell where only one candidate is possible due to other numbers in its row, column, and box.',
    example: 'The green cell is the naked single. The yellow cells are filled 5s that eliminate 5 as a candidate in the green cell.',
    relevantDifficulties: [Difficulty.easy, Difficulty.medium, Difficulty.hard, Difficulty.master, Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 5, 0, 0, 0, 0], // 5 in the same column
      [5, 0, 0, 0, 0, 0, 0, 0, 0], // 5 in the same row
      [0, 0, 0, 0, 0, 0, 0, 0, 5], // 5 in the same box
    ],
    highlightCells: [
      [7, 4], // the naked single
      [6, 4], // 5 in the same column
      [7, 0], // 5 in the same row
      [8, 8], // 5 in the same box
    ],
    solutionCell: [7, 4],
  ),
  Technique(
    name: 'Hidden Single',
    description: 'A candidate that only appears once in a row, column, or box, even if the cell has other candidates.',
    example: 'Only the green cell in row 5 can be 7. The yellow cells are filled numbers that block other cells in the row from being 7.',
    relevantDifficulties: [Difficulty.easy, Difficulty.medium, Difficulty.hard, Difficulty.master, Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 2, 3, 4, 0, 5, 6, 8, 9], // row 5, green cell at (4,4)
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [4, 4], // the hidden single (green)
      [4, 0], [4, 1], [4, 2], [4, 3], [4, 5], [4, 6], [4, 7], [4, 8], // yellow cells blocking row
    ],
    solutionCell: [4, 4],
  ),
  Technique(
    name: 'Locked Candidates',
    description: 'A candidate confined to a single row or column within a box, or vice versa.',
    example: 'All 2s in the top-left box are in row 2. So, 2 can be eliminated from other cells in row 2 outside the box.',
    relevantDifficulties: [Difficulty.medium, Difficulty.hard, Difficulty.master, Difficulty.evil],
    boardExample: [
      [2, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 2, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 2, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [0, 0], [1, 1], [2, 2], // 2s in the box
      [1, 4], // cell in row 2 outside the box
    ],
    highlightRow: [1],
    highlightBox: [0, 0],
  ),
  Technique(
    name: 'Naked Pair/Triple',
    description: 'Two/three cells in a unit (row, column, box) contain only the same two/three candidates, so those candidates can be removed from other cells in the unit.',
    example: 'Cells (3, 3) and (3, 6) are the only ones in row 4 with [3,8] as candidates. Remove 3 and 8 from other cells in row 4.',
    relevantDifficulties: [Difficulty.medium, Difficulty.hard, Difficulty.master, Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 3, 0, 0, 8, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [3, 3], [3, 6],
    ],
    highlightRow: [3],
  ),
  Technique(
    name: 'Hidden Pair/Triple',
    description: 'Two/three candidates only appear in two/three cells in a unit, so those cells must be those candidates.',
    example: 'In row 5, only cells (4, 2) and (4, 5) can be 4 or 9. These cells must be [4,9].',
    relevantDifficulties: [Difficulty.hard, Difficulty.master, Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 4, 0, 0, 9, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [4, 2], [4, 5],
    ],
    highlightRow: [4],
  ),
  Technique(
    name: 'X-Wing',
    description: 'A pattern where a candidate appears in exactly two cells in two different rows and columns, forming a rectangle.',
    example: 'In this example, 5 is a candidate in exactly two cells in rows 2 and 7, and those columns match. Remove 5 from those columns elsewhere.',
    relevantDifficulties: [Difficulty.master, Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 5, 0, 0, 0, 5],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 5, 0, 0, 0, 5],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [1, 4], [1, 8], [6, 4], [6, 8],
    ],
  ),
  Technique(
    name: 'Swordfish',
    description: 'An extension of X-Wing to three rows and columns.',
    example: 'In this example, 6 is a candidate in three cells in three rows and columns, forming a swordfish pattern.',
    relevantDifficulties: [Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 6, 0, 0, 0, 6],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 6, 0, 0, 0, 6],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 6, 0, 0, 0, 6],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [0, 4], [0, 8], [2, 4], [2, 8], [4, 4], [4, 8],
    ],
  ),
  Technique(
    name: 'XY-Wing',
    description: 'A three-cell pattern that allows you to eliminate a candidate from other cells.',
    example: 'Cells (2,2), (2,4), and (4,2) form an XY-Wing. If A is [2,3], B is [3,5], C is [2,5], and all see each other, eliminate 5 from cells that see both A and C.',
    relevantDifficulties: [Difficulty.master, Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 2, 3, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 2, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [2, 2], [2, 4], [4, 2],
    ],
  ),
  Technique(
    name: 'Coloring',
    description: 'Using colors to track candidate chains and eliminate possibilities.',
    example: 'If two chains of 7s connect, one color must be true, so eliminate 7s that see both.',
    relevantDifficulties: [Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [2, 2], [2, 4], [4, 2], [4, 4],
    ],
  ),
  Technique(
    name: 'Unique Rectangle',
    description: 'A pattern that would allow multiple solutions, so you can eliminate candidates to preserve uniqueness.',
    example: 'If four cells form a rectangle and only two candidates are present, eliminate those candidates from other cells.',
    relevantDifficulties: [Difficulty.master, Difficulty.evil],
    boardExample: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    highlightCells: [
      [2, 2], [2, 4], [4, 2], [4, 4],
    ],
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
    final cellSize = 28.0;
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    print('Technique: ${technique.name}, boardExample: ${technique.boardExample}');
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
            const SizedBox(height: 24),
            Text('Example', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (technique.boardExample != null)
              Center(
                child: StaticSudokuBoard(
                  board: technique.boardExample!,
                  highlightCells: technique.highlightCells,
                  candidates: technique.candidates,
                  solutionCell: technique.solutionCell,
                  highlightRow: technique.highlightRow,
                  highlightCol: technique.highlightCol,
                  highlightBox: technique.highlightBox,
                ),
              )
            else
              Container(
                height: 180,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Text('Visual Example Coming Soon', style: TextStyle(color: Colors.grey[600])),
              ),
            const SizedBox(height: 12),
            Text(technique.example, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class TechniquesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sortedTechniques = [...techniques]
      ..sort((a, b) {
        final diff = b.relevantDifficulties.length.compareTo(a.relevantDifficulties.length);
        if (diff != 0) return diff;
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