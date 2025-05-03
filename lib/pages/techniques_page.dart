import 'package:flutter/material.dart';
import 'package:sudoku/widgets/sudoku_board.dart';

class TechniquesPage extends StatelessWidget {
  const TechniquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solving Techniques'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTechniqueSection(
            title: 'Naked Single',
            description: 'When a cell has only one possible candidate.',
            boardExample: [
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 5, 0, 0, 0, 0],
              [5, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 5],
            ],
            highlightCells: [
              [7, 4],
              [6, 4],
              [7, 0],
              [8, 8],
            ],
            solutionCell: [7, 4],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'Hidden Single',
            description: 'When a number can only go in one cell within a row, column, or box.',
            boardExample: [
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [1, 2, 3, 4, 0, 5, 6, 8, 9],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
            ],
            highlightCells: [
              [4, 4],
              [4, 0], [4, 1], [4, 2], [4, 3], [4, 5], [4, 6], [4, 7], [4, 8],
            ],
            solutionCell: [4, 4],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'Locked Candidates',
            description: 'When a number in a box is confined to a single row or column.',
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
              [0, 0],
              [1, 1],
              [2, 2],
              [1, 4],
            ],
            solutionCell: [1, 4],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'Naked Pair',
            description: 'When two cells in a unit contain the same two candidates.',
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
              [3, 3],
              [3, 6],
            ],
            solutionCell: [3, 3],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'Hidden Pair',
            description: 'When two numbers can only go in two cells within a unit.',
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
              [4, 2],
              [4, 5],
            ],
            solutionCell: [4, 2],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'X-Wing',
            description: 'When a number appears in exactly two rows and two columns, forming a rectangle.',
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
              [1, 4],
              [1, 8],
              [6, 4],
              [6, 8],
            ],
            solutionCell: [1, 4],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'Swordfish',
            description: 'An advanced version of X-Wing using three rows and columns.',
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
              [0, 4],
              [0, 8],
              [2, 4],
              [2, 8],
              [4, 4],
              [4, 8],
            ],
            solutionCell: [0, 4],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'XY-Wing',
            description: 'A pattern where one cell (pivot) has two candidates that can eliminate a candidate from another cell.',
            boardExample: [
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 2, 0, 3, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 5, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
            ],
            highlightCells: [
              [2, 2],
              [2, 4],
              [4, 2],
            ],
            solutionCell: [2, 2],
          ),
          const SizedBox(height: 24),
          _buildTechniqueSection(
            title: 'Unique Rectangle',
            description: 'A pattern that prevents multiple solutions by eliminating certain candidates.',
            boardExample: [
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 1, 0, 2, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 2, 0, 1, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0],
            ],
            highlightCells: [
              [2, 2],
              [2, 4],
              [4, 2],
              [4, 4],
            ],
            solutionCell: [2, 2],
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueSection({
    required String title,
    required String description,
    required List<List<int>> boardExample,
    required List<List<int>> highlightCells,
    required List<int> solutionCell,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SudokuBoard(
              board: boardExample,
              highlightCells: highlightCells,
              solutionCell: solutionCell,
              isReadOnly: true,
            ),
          ],
        ),
      ),
    );
  }
} 