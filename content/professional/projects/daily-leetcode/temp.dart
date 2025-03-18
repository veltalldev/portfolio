void mergeSortedArrays(List<int> nums1, int n1, List<int> nums2, int n2) {
  int readPtr1 = n1 - 1;
  int readPtr2 = n2 - 1;
  int writePtr = n1 + n2 - 1;

  while (readPtr1 >= 0 && readPtr2 >= 0) {
    if (nums1[readPtr1] > nums2[readPtr2]) {
      nums1[writePtr] = nums1[readPtr1];
      readPtr1--;
    } else {
      nums1[writePtr] = nums2[readPtr2];
      readPtr2--;
    }
    writePtr--;
  }
  if (readPtr1 == -1) {
    while (readPtr2 >= 0) {
      nums1[writePtr--] = nums2[readPtr2--];
    }
  }
  if (readPtr2 == -1) {
    // we're done, no more work to do
  }
}

void test(List<int> nums1, int n1, List<int> nums2, n2, List<int> expected) {
  mergeSortedArrays(nums1, n1, nums2, n2);
  assert(listEquals(nums1, expected));
}

bool listEquals(List<int> list1, List<int> list2) {
  bool listEqual = list1.length == list2.length;
  for (var i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      listEqual = false;
      break;
    }
  }
  return listEqual;
}

void main() {
  test([1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3, [1, 2, 2, 3, 5, 6]);
  test([1, 2, 3, 4, 5], 5, [], 0, [1, 2, 3, 4, 5]);
  test([0, 0, 0], 0, [1, 2, 3], 3, [1, 2, 3]);
  test([2, 2, 2, 0, 0, 0], 3, [2, 2, 2], 3, [2, 2, 2, 2, 2, 2]);
  test([1, 2, 3, 0, 0, 0], 3, [4, 5, 6], 3, [1, 2, 3, 4, 5, 6]);
  test([4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3, [1, 2, 3, 4, 5, 6]);
  test([1, 3, 5, 0, 0, 0], 3, [2, 4, 6], 3, [1, 2, 3, 4, 5, 6]);
  test([1, 0], 1, [2], 1, [1, 2]);
  test([-100, 0, 100, 0, 0, 0], 3, [-1000, 1000, 10000], 3, [
    -1000,
    -100,
    0,
    100,
    1000,
    10000,
  ]);
  test([-3, -2, -1, 0, 0, 0], 3, [-6, -5, -4], 3, [-6, -5, -4, -3, -2, -1]);

  print("All tests passed");
}
