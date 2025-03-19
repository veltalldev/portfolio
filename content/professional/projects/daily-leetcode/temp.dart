import 'dart:collection';

final test_case_1 = {
  "input_matrix": [
    ['B', 'B', 'W'],
    ['W', 'W', 'W'],
    ['W', 'W', 'W'],
    ['B', 'B', 'B'],
  ],
  "start_position": (2, 2),
  "new_color": 'G',
  "expected_output": [
    ['B', 'B', 'G'],
    ['G', 'G', 'G'],
    ['G', 'G', 'G'],
    ['B', 'B', 'B'],
  ],
};

/// final test Case 2: Small matrix with isolated regions
final test_case_2 = {
  "input_matrix": [
    ['R', 'R', 'B', 'B'],
    ['R', 'B', 'B', 'R'],
    ['B', 'B', 'R', 'R'],
    ['B', 'R', 'R', 'R'],
  ],
  "start_position": (0, 0),
  "new_color": 'Y',
  "expected_output": [
    ['Y', 'Y', 'B', 'B'],
    ['Y', 'B', 'B', 'R'],
    ['B', 'B', 'R', 'R'],
    ['B', 'R', 'R', 'R'],
  ],
};

/// final test Case 3: Larger matrix with complex pattern
final test_case_3 = {
  "input_matrix": [
    ['A', 'A', 'A', 'B', 'B', 'B'],
    ['A', 'C', 'A', 'B', 'C', 'B'],
    ['A', 'A', 'A', 'B', 'B', 'B'],
    ['C', 'C', 'C', 'C', 'C', 'C'],
    ['D', 'D', 'D', 'D', 'D', 'D'],
  ],
  "start_position": (1, 4),
  "new_color": 'X',
  "expected_output": [
    ['A', 'A', 'A', 'B', 'B', 'B'],
    ['A', 'C', 'A', 'B', 'X', 'B'],
    ['A', 'A', 'A', 'B', 'B', 'B'],
    ['C', 'C', 'C', 'C', 'C', 'C'],
    ['D', 'D', 'D', 'D', 'D', 'D'],
  ],
};

/// final test Case 4: Matrix with a single color
final test_case_4 = {
  "input_matrix": [
    ['S', 'S', 'S', 'S'],
    ['S', 'S', 'S', 'S'],
    ['S', 'S', 'S', 'S'],
  ],
  "start_position": (1, 1),
  "new_color": 'T',
  "expected_output": [
    ['T', 'T', 'T', 'T'],
    ['T', 'T', 'T', 'T'],
    ['T', 'T', 'T', 'T'],
  ],
};

/// final test Case 5: When the new color is the same as the original
final test_case_5 = {
  "input_matrix": [
    ['P', 'P', 'Q'],
    ['P', 'Q', 'Q'],
    ['Q', 'Q', 'Q'],
  ],
  "start_position": (0, 0),
  "new_color": 'P',

  /// Same as original color
  "expected_output": [
    ['P', 'P', 'Q'],
    ['P', 'Q', 'Q'],
    ['Q', 'Q', 'Q'],
  ],

  /// No change expected
};

/// final test Case 6: 1x1 matrix
final test_case_6 = {
  "input_matrix": [
    ['Z'],
  ],
  "start_position": (0, 0),
  "new_color": 'Y',
  "expected_output": [
    ['Y'],
  ],
};

/// final test Case 7: Edge case with border fill
final test_case_7 = {
  "input_matrix": [
    ['O', 'O', 'O', 'O', 'O'],
    ['O', 'X', 'X', 'X', 'O'],
    ['O', 'X', 'O', 'X', 'O'],
    ['O', 'X', 'X', 'X', 'O'],
    ['O', 'O', 'O', 'O', 'O'],
  ],
  "start_position": (0, 0),
  "new_color": 'F',
  "expected_output": [
    ['F', 'F', 'F', 'F', 'F'],
    ['F', 'X', 'X', 'X', 'F'],
    ['F', 'X', 'O', 'X', 'F'],
    ['F', 'X', 'X', 'X', 'F'],
    ['F', 'F', 'F', 'F', 'F'],
  ],
};

final test_case_8 = {
  "input_matrix": [
    ['Y'],
  ],
  "start_position": (0, 0),
  "new_color": 'Z',
  "expected_output": [
    ['Z'],
  ],
};

void test(Map testCase) {
  final input = testCase["input_matrix"];
  final pos = testCase["start_position"];
  final newColor = testCase["new_color"];
  final expected = testCase["expected_output"];

  // in-place modify
  floodFill(input, pos, newColor);
  assert(areMatricesEqual(input, expected));
}

void main(List<String> args) {
  test(test_case_1);
  test(test_case_2);
  test(test_case_3);
  test(test_case_4);
  test(test_case_5);
  test(test_case_6);
  test(test_case_7);
  test(test_case_8);

  print("All tests passed");
}

/// Compares two matrices to check if they are equal.
///
/// Returns true if matrices have the same dimensions and all elements match.
/// Returns false otherwise.
bool areMatricesEqual<T>(List<List<T>> matrix1, List<List<T>> matrix2) {
  // Check if matrices have the same number of rows
  if (matrix1.length != matrix2.length) {
    return false;
  }

  // Check each row
  for (int i = 0; i < matrix1.length; i++) {
    // Check if rows have the same number of columns
    if (matrix1[i].length != matrix2[i].length) {
      return false;
    }

    // Check each element in the row
    for (int j = 0; j < matrix1[i].length; j++) {
      if (matrix1[i][j] != matrix2[i][j]) {
        return false;
      }
    }
  }

  // All checks passed
  return true;
}

/// A utility function that provides detailed information about
/// differences when matrices don't match.
String compareMatricesWithDetails<T>(
  List<List<T>> matrix1,
  List<List<T>> matrix2,
) {
  StringBuffer result = StringBuffer();

  // Check dimensions
  if (matrix1.length != matrix2.length) {
    return 'Matrices have different number of rows: ${matrix1.length} vs ${matrix2.length}';
  }

  List<String> differences = [];

  // Check each row and cell
  for (int i = 0; i < matrix1.length; i++) {
    if (matrix1[i].length != matrix2[i].length) {
      return 'Row $i has different lengths: ${matrix1[i].length} vs ${matrix2[i].length}';
    }

    for (int j = 0; j < matrix1[i].length; j++) {
      if (matrix1[i][j] != matrix2[i][j]) {
        differences.add(
          'At position [$i][$j]: ${matrix1[i][j]} vs ${matrix2[i][j]}',
        );
      }
    }
  }

  if (differences.isEmpty) {
    return 'Matrices are identical';
  } else {
    result.writeln('Found ${differences.length} differences:');
    for (String diff in differences) {
      result.writeln('- $diff');
    }
    return result.toString();
  }
}

/// Utility to print a matrix in a readable format
void printMatrix<T>(List<List<T>> matrix) {
  for (var row in matrix) {
    print(row.join(' '));
  }
}

void floodFill(List<List<String>> image, (int, int) pos, String newColor) {
  var (row, col) = pos;
  if (image.length < row || image[0].length < col) return;
  final originalColor = image[row][col];
  if (originalColor == newColor) return;

  final queue = Queue<(int, int)>()..add(pos);
  // print("Original queue: $queue");
  while (queue.isNotEmpty) {
    (row, col) = queue.removeFirst();
    final neighbors = [
      (row, col + 1),
      (row + 1, col),
      (row, col - 1),
      (row - 1, col),
    ];
    // print("neighbors = $neighbors");
    for (var neighbor in neighbors) {
      final currentColor = getColorFromImage(neighbor, image);
      if (currentColor == originalColor) queue.add(neighbor);
    }
    // print("new queue: $queue");
    // process currently dequeued cell then move on
    image[row][col] = newColor;
  }
}

String getColorFromImage((int, int) pos, List<List<String>> image) {
  if (!isCellInBounds(pos, image)) return '';
  return image[pos.$1][pos.$2];
}

bool isCellInBounds((int, int) pos, List<List<String>> image) {
  final rows = image.length;
  final cols = image[0].length;
  return pos.$1 >= 0 && pos.$1 < rows && pos.$2 >= 0 && pos.$2 < cols;
}
