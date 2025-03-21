int countIslands(List<List<int>> grid) {
  // some edge cases
  if (grid.isEmpty) return 0;

  // setup
  int islandCount = 0;

  // main loop to find land
  grid.forEachCoordinate((x, y, value) {
    if (grid[x][y] == 1) {
      islandCount++;
      processIsland(x, y, grid); // dfs process
    }
  });
  return islandCount;
}

void processIsland(int x, int y, List<List<int>> grid) {
  if (!grid.isValidCoordinate(x, y) || grid[x][y] == 0) {
    return;
  }
  grid[x][y] = 0;
  for (var (nx, ny) in grid.getAdjacentCoordinates(x, y)) {
    processIsland(nx, ny, grid);
  }
}

extension GridExtension<T> on List<List<T>> {
  /// Iterates through each cell in the grid with its coordinates
  void forEachCoordinate(void Function(int x, int y, T value) callback) {
    for (int i = 0; i < length; i++) {
      for (int j = 0; j < this[i].length; j++) {
        callback(i, j, this[i][j]);
      }
    }
  }

  /// Returns the number of rows in the grid
  int get rows => length;

  /// Returns the number of columns in the grid (assumes uniform width)
  int get columns => isEmpty ? 0 : this[0].length;

  /// Checks if coordinates are within the grid boundaries
  bool isValidCoordinate(int x, int y) {
    return x >= 0 && x < rows && y >= 0 && y < columns;
  }

  /// Gets a list of valid adjacent coordinates (up, right, down, left)
  List<(int, int)> getAdjacentCoordinates(int x, int y) {
    final directions = [
      (-1, 0),
      (0, 1),
      (1, 0),
      (0, -1),
    ]; // up, right, down, left
    return directions
        .map((dir) => (x + dir.$1, y + dir.$2))
        .where((coord) => isValidCoordinate(coord.$1, coord.$2))
        .toList();
  }

  /// Gets a list of all coordinates in the grid as (x,y) pairs
  List<(int, int)> get allCoordinates {
    List<(int, int)> coords = [];
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        coords.add((i, j));
      }
    }
    return coords;
  }

  /// Maps each grid cell to a new value based on a transform function
  List<List<R>> mapGrid<R>(R Function(int x, int y, T value) transform) {
    return List.generate(
      rows,
      (i) => List.generate(columns, (j) => transform(i, j, this[i][j])),
    );
  }
}

// Helper for running tests
void runTest(String testName, List<List<int>> grid, int expected) {
  final actual = countIslands(grid);
  if (actual != expected) {
    throw Exception(
      'Test "$testName" failed: expected $expected but got $actual',
    );
  }
  print('Test "$testName" passed!');
}

void main() {
  // Test case 1: Single island
  runTest('Single island', [
    [1, 1, 1],
    [1, 1, 1],
    [1, 1, 1],
  ], 1);

  // Test case 2: No islands
  runTest('No islands', [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
  ], 0);

  // Test case 3: Multiple separate islands
  runTest('Multiple separate islands', [
    [1, 1, 0, 0, 0],
    [1, 1, 0, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 0, 1, 1],
  ], 3);

  // Test case 4: Diagonal islands (diagonals don't connect)
  runTest('Diagonal islands', [
    [1, 0, 1],
    [0, 0, 0],
    [1, 0, 1],
  ], 4);

  // Test case 5: Complex island shapes
  runTest('Complex island shapes', [
    [1, 1, 0, 0, 0],
    [1, 0, 0, 0, 1],
    [1, 0, 1, 0, 1],
    [0, 0, 1, 1, 1],
  ], 2);

  // Test case 6: Single row
  runTest('Single row', [
    [1, 0, 1, 0, 1],
  ], 3);

  // Test case 7: Single column
  runTest('Single column', [
    [1],
    [0],
    [1],
    [0],
    [1],
  ], 3);

  // Test case 8: Island with hole
  runTest('Island with hole', [
    [1, 1, 1, 1],
    [1, 0, 0, 1],
    [1, 0, 0, 1],
    [1, 1, 1, 1],
  ], 1);

  // Test case 9: Empty grid
  runTest('Empty grid', [], 0);

  // Test case 10: Larger grid with multiple islands
  runTest('Larger grid with multiple islands', [
    [1, 1, 0, 0, 0, 0, 1, 1],
    [1, 0, 0, 0, 0, 1, 1, 1],
    [0, 0, 0, 1, 1, 0, 0, 0],
    [0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0],
  ], 4);

  print('All tests passed!');
}
