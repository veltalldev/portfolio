---
title: "Finding Values in a Rotated Sorted Array: An Insight-First Approach"
date: 2025-02-19
lastmod: 2025-02-19
draft: false
description: "Understanding the rotated array search problem through progressive insights"
tags: ["algorithms", "binary-search", "dart", "problem-solving"]
categories: ["problem-solving"]
series: ["algorithm-deep-dives"]
slug: "rotated-binary-search"
math: true
toc: true
readingTime: 15
---

{{% problem %}}
## Problem Statement

Given an integer array that was sorted in ascending order and then rotated at an unknown pivot, find a target value in O(log n) time.

### Input Format
- A rotated sorted array of integers `nums`
- A target integer value to find

### Output Format
- The index of the target if found, -1 otherwise

### Constraints
- `1 <= nums.length <= 5000`
- All values in `nums` are unique
- `nums` was originally sorted in ascending order before being rotated
- Time Complexity must be O(log n)
{{% /problem %}}

### Examples

{{< example
    number="1"
    input="nums = [15, 18, 20, 22, 25, 28, 2, 4, 6, 8, 10, 13], target = 8"
    input-type="int[] and target int"
    output="9"
    output-type="int (index of target)" >}}
The array was rotated 6 positions to the right.
Target value 8 is found at index 9.
{{< /example >}}

{{< section-divider >}}

## Initial Analysis

The fundamental challenge here isn't just finding a value - it's finding it in logarithmic time in an array that's "almost" sorted. The O(log n) requirement immediately suggests {{< emphasis >}}binary search{{< /emphasis >}}, but rotation breaks the core property that makes binary search work.

Let's dig deeper into what exactly breaks - and what remains intact.

## What Makes Binary Search Work?

In a sorted array, we have a fascinating relationship between {{< emphasis >}}two completely different types of information{{< /emphasis >}}:
1. {{< emphasis >}}Position{{< /emphasis >}}: Where a value appears in the array
2. {{< emphasis >}}Magnitude{{< /emphasis >}}: How large that value is

{{< visualization 
    src="svg/rotated-array-search/original-sorted.svg"
    title="" >}}
{{< /visualization >}}

Sorting creates a mapping between these unrelated concepts. When an array is sorted, "comes before" in position means {{< emphasis >}}exactly the same thing{{< /emphasis >}} as "less than" in magnitude. This equivalence lets us use magnitude comparisons (which we can check directly) to make conclusions about positions (which we're trying to determine).

{{< section-divider >}}

## The Effect of Rotation

When we rotate an array, we disrupt this clean mapping between position and magnitude. In our example:
```javascript
[15, 18, 20, 22, 25, 28, 2, 4, 6, 8, 10, 13]
```

{{< visualization 
    src="svg/rotated-array-search/rotated.svg"
    title="" >}}
{{< /visualization >}}

We can no longer say that "comes before" means "less than". The `2` comes after `28` despite being smaller. This is why standard binary search fails - it relies on position and magnitude having a consistent relationship throughout the array.

But something interesting remains. While the global relationship is broken, we still have local relationships. Within any continuous segment that doesn't cross the rotation point, "comes before" still means "less than".

```dart
// Two sorted sequences in our rotated array
final leftSequence = [15, 18, 20, 22, 25, 28];
final rightSequence = [2, 4, 6, 8, 10, 13];

// Demonstrating local ordering remains intact
bool isLocallySorted(List<int> sequence) {
  for (var i = 0; i < sequence.length - 1; i++) {
    if (sequence[i] >= sequence[i + 1]) return false;
  }
  return true;
}

// Both sequences maintain their local ordering
assert(isLocallySorted(leftSequence));
assert(isLocallySorted(rightSequence));
```

{{< visualization 
    src="svg/rotated-array-search/two-sequence.svg"
    title="" >}}
{{< /visualization >}}

{{< section-divider >}}

## A Key Insight About Order

{{< notice >}}
Here's a crucial observation: In a sorted sequence:
- If x < y, then we must encounter x before y
- If x > y, then we must encounter y before x
{{< /notice >}}

This might seem obvious, but it gives us a powerful tool. By comparing {{< emphasis >}}magnitudes{{< /emphasis >}} (which we can do directly), we can determine the {{< emphasis >}}order in which values must appear{{< /emphasis >}} (position information).

## Using This Insight

Let's say we're looking for a target value. An ordered way to search for its position is to start from the minimum value and follow the direction of growth. In doing so, we expect to find the following values of interest:

{{< visualization 
    src="svg/rotated-array-search/traversal-order.svg"
    title="" >}}
{{< /visualization >}}

1. the minimum value itself
2. {{< emphasis >}}potentially{{< /emphasis >}} the search target
3. the right boundary
4. the left boundary
5. {{< emphasis >}}potentially{{< /emphasis >}} the search target
6. the maximum value

### Implication
The {{< emphasis >}}position{{< /emphasis >}} of the search target can be inferred from its {{< emphasis >}}value comparison{{< /emphasis >}} with known "anchor" points, i.e. the boundaries of the array: indices `0` and `n-1`

#### Case 1
{{< visualization 
    src="svg/rotated-array-search/right-half-target.svg"
    title="" >}}
{{< /visualization >}}

#### Case 2
{{< visualization 
    src="svg/rotated-array-search/left-half-target.svg"
    title="" >}}
{{< /visualization >}}

### Logical Leap
Given this insight, we can determine which of the two sequences contains the search target, purely just by comparing its value to them.

```dart
final target = 8;
final rightBoundary = rotatedArray.last; // 13

// One comparison reveals sequence membership
if (target < rightBoundary) {
  print('$target < $rightBoundary, target must be in right sequence');
  // Will search in [2, 4, 6, 8, 10, 13]
} else {
  print('$target >= $rightBoundary, target must be in left sequence');
}
```

With a single comparison, we can determine which half of the array contains our target.

{{< section-divider >}}

## Problem Reduction: Find Minimum Value

Once we know which half contains our target, we need to perform binary search on that half. This requires knowing the boundaries of our search space:
- One boundary is the array end (we have this)
- The other boundary is the sequence divider (we need to find this)

#### Case 1
{{< visualization 
    src="svg/rotated-array-search/right-binary.svg"
    title="" >}}
{{< /visualization >}}

#### Case 2
{{< visualization 
    src="svg/rotated-array-search/left-binary.svg"
    title="" >}}
{{< /visualization >}}

{{< section-divider >}}

## Finding the Sequence Divider
Finding this sequence divider (which is the maximum value for the left sequence or minimum value for the right sequence) becomes our next challenge. However, the same considerations apply:

- We still need to do it in $O(\log n)$ time, which means {{< emphasis >}}Binary Search{{< /emphasis >}}
- We still apply our understanding of sortedness to infer the position of the minimum value based on the values of the array. But which values?
- {{< emphasis >}}Binary Search{{< /emphasis >}} typically makes use of the middle value to determine whether we recurse on the left or on the right, so let's look at that value: 

$$mid = \frac{left + right}{2}$$
Let's look at a particular example: `[25, 28, 2, 4, 6, 8, 10, 13, 15, 18, 20, 22]`

{{< visualization 
    src="svg/rotated-array-search/min-left.svg"
    title="" >}}
{{< /visualization >}}

If only we had a way to tell that the minimum value is to our left. Let's see the mirror case for inspiration: `[8, 10, 13, 15, 18, 20, 22, 25, 28, 2, 4, 6]`

{{< visualization 
    src="svg/rotated-array-search/min-right.svg"
    title="" >}}
{{< /visualization >}}

That's it! We still know the boundary values, and we can find the middle value from them. The position of the minimum value influences them both, but we can think of it in a more intuitive way:

{{< notice >}}
If the minimum value is closer to the boundaries (belonging to the right half), then the boundary values are **closer** to the minimum, thereby being smaller in value.

This means that, intuitively, if the sequence divider is on the right half, then the boundary values must be smaller than the middle value. We can also verify this with the "order of encounter" technique we discussed earlier.

This gives us a clean rule:

- If `arr[mid] < arr[right]`, we recurse on the left (Case 1)
- If `arr[mid] > arr[right]`, we recurse on the right (Case 2)
{{< /notice >}}

```dart
int findMinimum(List<int> arr) {
  var left = 0;
  var right = arr.length - 1;
  
  while (left < right) {
    final mid = (left + right) ~/ 2;
    
    // Compare middle with right boundary
    if (arr[mid] < arr[right]) {
      print('${arr[mid]} < ${arr[right]}, minimum must be in left half');
      right = mid;
    } else {
      print('${arr[mid]} > ${arr[right]}, minimum must be in right half');
      left = mid + 1;
    }
  }
  
  return left;
}

// Example usage with our array
final rotatedArray = [15, 18, 20, 22, 25, 28, 2, 4, 6, 8, 10, 13];
final minIndex = findMinimum(rotatedArray);
print('Minimum value ${rotatedArray[minIndex]} found at index $minIndex');
```

## Complexity Analysis

#### Time Complexity
- Finding rotation point: {{< math tex="O(\log n)" >}}
- Determining chosen half: {{< math tex="O(1)" >}}
- Binary search on chosen half: {{< math tex="O(\log n)" >}}

  Total: {{< math tex="O(\log n)" >}}

#### Space Complexity
- Only storing a constant number of pointers and values

  Total: {{< math tex="O(1)" >}}

{{< section-divider >}}

## Key Takeaways

1. **Constraints Guide Discovery**
   - O(log n) requirement points to binary search
   - Look for what remains ordered when global order breaks
   - Limited information forces deeper analysis of available data

2. **Sortedness Bridges Value and Position**
   - Sorting creates a mapping between position and magnitude
   - This mapping is what makes binary search possible
   - Rotations don't destroy this property everywhere

3. **Partial Invariants Matter**
   - Local order remains even when global order breaks
   - Finding and leveraging these "islands" of order is crucial

4. **Small Checks Yield Big Clues**
   - One comparison with the boundary reveals sequence membership
   - You don't always need complete information upfront

## Learning Outcomes

1. Value of understanding fundamental properties (sortedness, ordering)
2. Importance of identifying what remains intact when structure breaks
3. Power of using simple comparisons to gain position information
4. Technique of leveraging partial ordering in search problems

## Additional Thoughts
For those wanting a deeper understanding:
Binary search is fundamentally about intelligently eliminating portions of the search space. It doesn't necessarily need to divide the space in half - it just needs to:
1. Divide the search space into sections
2. Have a way to identify which sections cannot contain our answer
3. Recursively focus on the promising sections

In our case, we do divide the arrays in half because there is no advantage in other subdivision choices.