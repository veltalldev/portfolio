class LinkNode<T> {
  final T _value;
  LinkNode? next = null;
  LinkNode(this._value, [this.next]);

  T get value => _value;
}

LinkNode? buildLinkList(List<int> values, int pos) {
  if (values.isEmpty) return null;
  final head = LinkNode(values[0]);
  LinkNode current = head;
  LinkNode? loopPos = null;
  for (var i = 1; i < values.length; i++) {
    current.next = LinkNode(values[i]);
    if (pos == i - 1) {
      loopPos = current;
    }
    current = current.next!;
  }
  if (pos > -1) current.next = loopPos;
  return head;
}

LinkNode? detectCycleStart(LinkNode? head) {
  if (head == null || head.next == null) return null;

  LinkNode? slow = head;
  LinkNode? fast = head;
  bool hasCycle = false;

  while (fast != null && fast.next != null) {
    slow = slow!.next;
    fast = fast.next!.next;

    if (slow == fast) {
      hasCycle = true;
      break;
    }
  }

  // default exit condition is finding a null tail
  if (!hasCycle) return null;

  // else, we find it
  slow = head;
  while (slow != fast) {
    // walk both forward, one step at a time
    slow = slow!.next; // will cover distancce `x`
    fast = fast!.next; // will cover distance `z`
  }

  return slow;
}

void main(List<String> args) {
  testCycleDetection();
}

void testCycleDetection() {
  // Test case 1: [3,2,0,-4] with pos=1
  var list1 = buildLinkList([3, 2, 0, -4], 1);
  var result1 = detectCycleStart(list1);
  print("Test 1: ${result1?.value == 2 ? 'PASS' : 'FAIL'}");

  // Test case 2: [1,2] with pos=0
  var list2 = buildLinkList([1, 2], 0);
  var result2 = detectCycleStart(list2);
  print("Test 2: ${result2?.value == 1 ? 'PASS' : 'FAIL'}");

  // Test case 3: [1] with pos=-1 (no cycle)
  var list3 = buildLinkList([1], -1);
  var result3 = detectCycleStart(list3);
  print("Test 3: ${result3 == null ? 'PASS' : 'FAIL'}");

  // Test case 4: Empty list
  var list4 = buildLinkList([], -1);
  var result4 = detectCycleStart(list4);
  print("Test 4: ${result4 == null ? 'PASS' : 'FAIL'}");
}
