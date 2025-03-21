import 'dart:collection';

void main() {
  // Test suite
  testSimpleSquare();
  testOriginalExample();
  testLineHorizontal();
  testLineVertical();
  testAllLand();
  testSingleCell();
  testComplexShape();
  testLShapedIsland();
  testUShapedIsland();

  print("All tests passed!");
}

void test(List<List<int>> grid, int expected) {
  final actual = countPerimeterOfIsland(grid);
  print("actual = $actual");
  assert(actual == expected);
}

int countPerimeterOfIsland(List<List<int>> grid) {
  // some edge cases
  if (grid.length == 0) return 0;

  // setup
  int perimeter = 0;
  final geo = padGridWithWater(grid);

  // main loop to find land
  for (var i = 1; i < geo.length; i++) {
    for (var j = 1; j < geo[0].length; j++) {
      if (geo[i][j] == 1) {
        // BFS intialization
        final queue = Queue();
        queue.add((i, j));
        geo[i][j] = 2;
        // main loop
        while (queue.isNotEmpty) {
          final (a, b) = queue.removeFirst();
          final neighbors = [(a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1)];
          // each neighbor is either water or land, process accordingly
          for (var (x, y) in neighbors) {
            if (geo[x][y] == 0) {
              perimeter++;
            }
            if (geo[x][y] == 1) {
              queue.add((x, y));
              geo[x][y] = 2; // update current cell
            }
          }
        }
        break; // optional short circuit
      }
    }
  }

  return perimeter;
}

padGridWithWater(List<List<int>> grid) {
  final m = grid[0].length;
  return <List<int>>[
    List.filled(m + 2, 0),
    for (var row in grid) [0, ...row, 0],
    List.filled(m + 2, 0),
  ];
}

void printMatrix<T>(List<List<T>> matrix) {
  for (var row in matrix) {
    print(row.join(' '));
  }
}

// Helper for running tests
void runTest(String testName, List<List<int>> grid, int expected) {
  final actual = countPerimeterOfIsland(grid);
  if (actual != expected) {
    throw Exception(
      'Test "$testName" failed: expected $expected but got $actual',
    );
  }
  print('Test "$testName" passed!');
}

// Test cases
void testOriginalExample() {
  final grid = [
    [0, 1, 0, 0],
    [1, 1, 1, 0],
    [0, 1, 0, 0],
    [1, 1, 0, 0],
  ];
  runTest("Original Example", grid, 16);
}

void testSimpleSquare() {
  final grid = [
    [1, 1],
    [1, 1],
  ];
  runTest("Simple Square", grid, 8);
}

void testLineHorizontal() {
  final grid = [
    [1, 1, 1],
  ];
  runTest("Horizontal Line", grid, 8);
}

void testLineVertical() {
  final grid = [
    [1],
    [1],
    [1],
  ];
  runTest("Vertical Line", grid, 8);
}

void testAllLand() {
  final grid = [
    [1, 1, 1],
    [1, 1, 1],
    [1, 1, 1],
  ];
  runTest("All Land", grid, 12);
}

void testSingleCell() {
  final grid = [
    [1],
  ];
  runTest("Single Cell", grid, 4);
}

void testComplexShape() {
  final grid = [
    [0, 1, 0, 0, 0],
    [1, 1, 1, 1, 0],
    [0, 1, 0, 1, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 0],
  ];
  runTest("Complex Shape", grid, 20);
}

void testLShapedIsland() {
  final grid = [
    [1, 0],
    [1, 0],
    [1, 1],
  ];
  runTest("L-Shaped Island", grid, 10);
}

void testUShapedIsland() {
  final grid = [
    [1, 0, 1],
    [1, 0, 1],
    [1, 1, 1],
  ];
  runTest("U-Shaped Island", grid, 16);
}
