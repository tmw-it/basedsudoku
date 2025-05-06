import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/utils/technique_example_generator.dart';

void main() {
  test('Generate technique examples', () {
    print('Generating technique examples...\n');

    // Naked Single
    print('=== Naked Single ===');
    final nakedSingle = TechniqueExampleGenerator.generateNakedSingle();
    TechniqueExampleGenerator.printExample(nakedSingle);
    print('\n');

    // Hidden Single
    print('=== Hidden Single ===');
    final hiddenSingle = TechniqueExampleGenerator.generateHiddenSingle();
    TechniqueExampleGenerator.printExample(hiddenSingle);
    print('\n');

    // Locked Candidates
    print('=== Locked Candidates ===');
    final lockedCandidates = TechniqueExampleGenerator.generateLockedCandidates();
    TechniqueExampleGenerator.printExample(lockedCandidates);
    print('\n');

    // Naked Pair
    print('=== Naked Pair ===');
    final nakedPair = TechniqueExampleGenerator.generateNakedPair();
    TechniqueExampleGenerator.printExample(nakedPair);
    print('\n');

    // Hidden Pair
    print('=== Hidden Pair ===');
    final hiddenPair = TechniqueExampleGenerator.generateHiddenPair();
    TechniqueExampleGenerator.printExample(hiddenPair);
    print('\n');

    // X-Wing
    print('=== X-Wing ===');
    final xWing = TechniqueExampleGenerator.generateXWing();
    TechniqueExampleGenerator.printExample(xWing);
    print('\n');

    // Swordfish
    print('=== Swordfish ===');
    final swordfish = TechniqueExampleGenerator.generateSwordfish();
    TechniqueExampleGenerator.printExample(swordfish);
    print('\n');

    // XY-Wing
    print('=== XY-Wing ===');
    final xyWing = TechniqueExampleGenerator.generateXYWing();
    TechniqueExampleGenerator.printExample(xyWing);
    print('\n');

    // Unique Rectangle
    print('=== Unique Rectangle ===');
    final uniqueRectangle = TechniqueExampleGenerator.generateUniqueRectangle();
    TechniqueExampleGenerator.printExample(uniqueRectangle);
    print('\n');
  });
} 