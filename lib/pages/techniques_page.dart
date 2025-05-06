import 'package:flutter/material.dart';
import 'package:sudoku/theme/nord_theme.dart';

class TechniquesPage extends StatelessWidget {
  const TechniquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solving Techniques'),
        backgroundColor: NordColors.nord0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTechniqueCard(
            'Single Candidate',
            'When a cell has only one possible number, that number must be the solution for that cell. This is the most basic technique and often the first step in solving a puzzle.\n\n'
            'Example: If a cell can only contain the number 5 (because all other numbers 1-9 are already present in its row, column, or box), then 5 must be the solution for that cell.',
          ),
          _buildTechniqueCard(
            'Single Position',
            'When a number can only go in one position within a row, column, or box, that must be its position. This technique looks at where a specific number can be placed.\n\n'
            'Example: In a row, if the number 7 can only be placed in one cell (because all other cells already have numbers or cannot contain 7), then that cell must contain 7.',
          ),
          _buildTechniqueCard(
            'Candidate Lines',
            'If a number can only appear in one row or column within a box, it can be eliminated from that row or column in other boxes. This creates a "line" of influence.\n\n'
            'Example: If in box 1 (top-left), the number 3 can only appear in the middle row, then 3 can be eliminated from the middle row of boxes 2 and 3, even if those cells could originally contain 3.',
          ),
          _buildTechniqueCard(
            'Double Pairs',
            'When two cells in a row, column, or box can only contain the same two numbers, those numbers can be eliminated from other cells in that unit. This creates a strong constraint.\n\n'
            'Example: If two cells in a row can only contain 4 and 7, then no other cell in that row can contain 4 or 7, even if they were previously possible candidates.',
          ),
          _buildTechniqueCard(
            'Hidden Pairs',
            'When two numbers can only appear in the same two cells within a row, column, or box, other candidates can be eliminated from those cells. This is like finding a secret relationship between numbers.\n\n'
            'Example: If in a row, the numbers 2 and 5 can only appear in cells A and B (even though these cells might have other candidates), then cells A and B must contain 2 and 5 in some order, and all other candidates can be removed.',
          ),
          _buildTechniqueCard(
            'X-Wing',
            'When a number can only appear in two positions in two different rows (or columns), and these positions form a rectangle, that number can be eliminated from the corresponding columns (or rows). This creates a powerful elimination pattern.\n\n'
            'Example: If the number 6 can only appear in cells (1,3) and (1,7) in row 1, and in cells (4,3) and (4,7) in row 4, forming a rectangle, then 6 can be eliminated from all other cells in columns 3 and 7.',
          ),
          _buildTechniqueCard(
            'Swordfish',
            'An extension of X-Wing where a number can only appear in three positions in three different rows (or columns), forming a pattern that allows elimination in the corresponding columns (or rows). This is like an X-Wing with an extra row/column.\n\n'
            'Example: If the number 8 can only appear in three specific cells in each of three different rows, and these cells align in three columns, then 8 can be eliminated from all other cells in those three columns.',
          ),
          _buildTechniqueCard(
            'XY-Wing',
            'When one cell (the pivot) has two candidates (XY) and can see two other cells with candidates (XZ and YZ), any cell that can see all three cells cannot contain Z. This creates a chain of eliminations.\n\n'
            'Example: If cell A has candidates 2,3; cell B has candidates 2,7; and cell C has candidates 3,7; then any cell that can see all three cells cannot contain 7, because either cell A must be 2 (making cell B 7) or cell A must be 3 (making cell C 7).',
          ),
          _buildTechniqueCard(
            'XYZ-Wing',
            'Similar to XY-Wing, but with three candidates (XYZ) in the pivot cell and three other cells with pairs of these candidates. This creates an even more complex elimination pattern.\n\n'
            'Example: If cell A has candidates 2,3,7; cell B has candidates 2,7; cell C has candidates 3,7; and cell D has candidates 2,3; then any cell that can see all four cells cannot contain 7, because the pivot cell must contain one of 2 or 3, forcing 7 into either cell B or C.',
          ),
          _buildTechniqueCard(
            'Unique Rectangle',
            'A pattern where four cells form a rectangle with the same two candidates in each cell. This can be used to eliminate candidates and avoid multiple solutions. This technique relies on the fact that a valid Sudoku puzzle must have a unique solution.\n\n'
            'Example: If four cells forming a rectangle all have candidates 1,2, and these are the only cells in their respective rows and columns that can contain 1 or 2, then one of the cells must contain a different number to avoid creating multiple solutions.',
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: NordColors.nord1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: NordColors.nord4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: NordColors.nord4,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 