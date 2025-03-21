T reduce<T, E>(
  List<E> items,
  T Function(T accumulator, E item) combine,
  T initialValue,
) {
  T result = initialValue;
  for (var item in items) {
    result = combine(result, item);
  }
  return result;
}

void main() {
  print('Running reduce function tests...');

  // Test 1: Sum of integers
  {
    final numbers = [1, 2, 3, 4, 5];
    final sum = reduce<int, int>(numbers, (acc, item) => acc + item, 0);
    assert(sum == 15, 'Sum of integers should be 15');
  }

  // Test 2: Product of integers
  {
    final numbers = [1, 2, 3, 4, 5];
    final product = reduce<int, int>(numbers, (acc, item) => acc * item, 1);
    assert(product == 120, 'Product of integers should be 120');
  }

  // Test 3: Concatenate strings
  {
    final words = ['Hello', ' ', 'world', '!'];
    final sentence = reduce<String, String>(
      words,
      (acc, item) => acc + item,
      '',
    );
    assert(sentence == 'Hello world!', 'String concatenation should match');
  }

  // Test 4: Find maximum value
  {
    final numbers = [3, 7, 2, 9, 5];
    final max = reduce<int, int>(
      numbers,
      (acc, item) => acc > item ? acc : item,
      numbers[0],
    );
    assert(max == 9, 'Maximum value should be 9');
  }

  // Test 5: Count occurrences in a list
  {
    final items = ['apple', 'banana', 'apple', 'cherry', 'banana', 'apple'];
    final counts = reduce<Map<String, int>, String>(items, (acc, item) {
      acc[item] = (acc[item] ?? 0) + 1;
      return acc;
    }, {});
    assert(counts['apple'] == 3, 'Apple count should be 3');
    assert(counts['banana'] == 2, 'Banana count should be 2');
    assert(counts['cherry'] == 1, 'Cherry count should be 1');
  }

  // Test 6: Transform data types
  {
    final stringNumbers = ['1', '2', '3', '4', '5'];
    final sum = reduce<int, String>(
      stringNumbers,
      (acc, item) => acc + int.parse(item),
      0,
    );
    assert(sum == 15, 'Sum of parsed numbers should be 15');
  }

  // Test 7: Handle empty list
  {
    final emptyList = <int>[];
    final sum = reduce<int, int>(emptyList, (acc, item) => acc + item, 0);
    assert(sum == 0, 'Empty list should return initial value');
  }

  // Test 8: Apply complex transformations
  {
    final transactions = [
      {'amount': 100, 'type': 'deposit'},
      {'amount': 50, 'type': 'withdrawal'},
      {'amount': 200, 'type': 'deposit'},
      {'amount': 25, 'type': 'withdrawal'},
    ];

    final balance = reduce<int, Map<String, dynamic>>(transactions, (
      acc,
      item,
    ) {
      if (item['type'] == 'deposit') {
        return acc + item['amount'] as int;
      } else {
        return acc - item['amount'] as int;
      }
    }, 0);
    assert(balance == 225, 'Final balance should be 225');
  }

  // Test 9: Combine objects with custom logic
  {
    final persons = [
      {'name': 'Alice', 'age': 25},
      {'name': 'Bob', 'age': 30},
      {'name': 'Charlie', 'age': 35},
    ];

    final result = reduce<Map<String, dynamic>, Map<String, dynamic>>(persons, (
      acc,
      person,
    ) {
      acc['totalAge'] = (acc['totalAge'] ?? 0) + person['age'] as int;
      acc['names'] = [...(acc['names'] ?? []), person['name']];
      return acc;
    }, {'totalAge': 0, 'names': []});

    assert(result['totalAge'] == 90, 'Total age should be 90');

    // Check that names list contains the expected values
    final namesList = result['names'] as List;
    assert(namesList.length == 3, 'Names list should have 3 items');
    assert(namesList[0] == 'Alice', 'First name should be Alice');
    assert(namesList[1] == 'Bob', 'Second name should be Bob');
    assert(namesList[2] == 'Charlie', 'Third name should be Charlie');
  }

  // Test 10: Calculate running totals
  {
    final numbers = [1, 2, 3, 4, 5];
    final runningTotals = reduce<List<int>, int>(numbers, (acc, item) {
      final lastSum = acc.isEmpty ? 0 : acc.last;
      return [...acc, lastSum + item];
    }, <int>[]);

    // Check length and values
    assert(runningTotals.length == 5, 'Running totals should have 5 items');
    assert(runningTotals[0] == 1, 'First running total should be 1');
    assert(runningTotals[1] == 3, 'Second running total should be 3');
    assert(runningTotals[2] == 6, 'Third running total should be 6');
    assert(runningTotals[3] == 10, 'Fourth running total should be 10');
    assert(runningTotals[4] == 15, 'Fifth running total should be 15');
  }

  // Test 11: Handle non-commutative operations (subtraction)
  {
    final numbers = [10, 5, 3];
    final result = reduce<int, int>(numbers, (acc, item) => acc - item, 0);
    assert(
      result == -18,
      'Subtraction result should be -18',
    ); // (0-10)-5-3 = -18
  }

  // Test 12: Handle complex initial value
  {
    final items = ['a', 'b', 'c'];
    final result = reduce<Map<String, int>, String>(items, (acc, item) {
      acc[item] = (acc[item] ?? 0) + 1;
      return acc;
    }, {'x': 5, 'y': 10});

    assert(result['x'] == 5, 'Initial x value should be preserved');
    assert(result['y'] == 10, 'Initial y value should be preserved');
    assert(result['a'] == 1, 'Count for a should be 1');
    assert(result['b'] == 1, 'Count for b should be 1');
    assert(result['c'] == 1, 'Count for c should be 1');
  }

  // Test 13: Single element list
  {
    final singleItem = [42];
    final result = reduce<int, int>(singleItem, (acc, item) => acc + item, 0);
    assert(result == 42, 'Single item reduction should be 42');
  }

  // Test 14: Function that ignores elements
  {
    final items = [1, 2, 3, 4, 5];
    final constant = reduce<int, int>(
      items,
      (acc, _) => acc, // Ignores all elements
      99,
    );
    assert(constant == 99, 'Constant function should return initial value');
  }

  // Test 15: Async operations simulation
  {
    final operations = ['op1', 'op2', 'op3'];
    final results = reduce<Map<String, String>, String>(operations, (acc, op) {
      acc[op] = 'Result of $op';
      return acc;
    }, {});
    assert(results['op1'] == 'Result of op1', 'op1 result should match');
    assert(results['op2'] == 'Result of op2', 'op2 result should match');
    assert(results['op3'] == 'Result of op3', 'op3 result should match');
  }

  print('\nAll tests passed successfully!');
}
