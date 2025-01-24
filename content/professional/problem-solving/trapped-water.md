---
title: "The Trapped Water Problem: Journey to an Elegant Solution"
date: 2024-01-23
lastmod: 2024-01-23
draft: false
description: "An in-depth development of monotonic stack technique and further optimization"
tags: ["algorithms", "monotonic-stack", "two-pointer", "problem-solving"]
categories: ["problem-solving"]
series: ["algorithm-deep-dives"]
slug: "trapped-water"
math: true
toc: true
---

{{% problem %}}
## Problem Statement

Given a list of n non-negative integers representing an elevation map where the width of each bar is 1, compute how much water can be trapped after raining.

### Input Format
- An array `height` of n non-negative integers where `height[i]` represents the height of the wall at position i. This wall has a width of 1 length unit.

### Output Format
- A single integer representing the total units of water that can be trapped

### Constraints
- `n == height.length`
- `1 <= n <= 2 * 10^4`
- `0 <= height[i] <= 10^5`
{{% /problem %}}

### Examples

{{< example
    number="1"
    input="height = [0,1,0,2,1,0,1,3,2,1,2,1]"
    input-type="int[] where 0 ≤ height[i] ≤ 10⁵"
    output="6"
    output-type="int (total units of water)" >}}
The above elevation map is represented by array [0,1,0,2,1,0,1,3,2,1,2,1]. 
After rain, water can be trapped between the blocks.
The total volume of water trapped is 6 units.
{{< /example >}}

{{< example 
    number="2"
    input="height = [4,2,0,3,2,5]"
    input-type="int[] where 0 ≤ height[i] ≤ 10⁵"
    output="9"
    output-type="int (total units of water)" >}}
There are 2 tall walls on the left and right (bounded at height 4), the rest can hold: 2, 4, 1, 2 units of water for a total of 9.
{{< /example >}}

{{< example
    number="3"
    input="height = [0]"
    input-type="int[]"
    output="0"
    output-type="int" >}}
No water can be trapped with a single wall.
{{< /example >}}

{{< section-divider >}}

## Initial Analysis

The fundamental challenge lies in determining each pillar's contribution to the total water volume. From a purely analytical perspective, we can identify that each pillar's contribution depends on three key factors:
1. Its own height
2. The height of the tallest wall to its left (left wall)
3. The height of the tallest wall to its right (right wall)

However, the contribution is definitive and not variable based on the surrounding context; we simply don't have the information to say what it is. This is different from saying that the quantity is undefined, indeterminate, or variable. Each pillar contributes a specific amount independent of what the other can contribute. This means we can transform the aggregate quantity we are seeking (i.e. total amount of rainwater) to a simple sum of water contribution by each pillar.

This three-way dependency initially suggests we might need multiple passes through the array to find the information needed for each pillar. However, deeper analysis reveals more structure we can exploit.

## Breaking Down the Ambiguity

When processing any given pillar, we immediately have two pieces of information:
- The pillar's own height (current element)
- The tallest wall to its left (tracked as we process elements)

While we don't yet know the height of the tallest wall to the right, we can establish clear bounds:
- Minimum contribution: 0
- Maximum contribution: left_wall - current_height (bounded by the shorter of the two walls)


{{< visualization 
    src="svg/trapped-water/setup.svg"
    title="Initial problem visualization with fundamental ambiguity" >}}
{{< /visualization >}}

Even in cases where the left wall is shorter than the current pillar, these bounds hold true - the maximum being negative simply means the only possible contribution is 0.

{{< section-divider >}}

## The Path to Monotonic Stack

The key insight emerges when we consider resolution conditions. A pillar's contribution becomes definitive in two scenarios:
1. Finding a wall at least as tall as the left wall
{{< visualization
    src="svg/trapped-water/definitive.svg"
    title="Premature but definitive right wall">}}
{{< /visualization >}}

2. Reaching the end of the array
{{< visualization
    src="svg/trapped-water/end.svg"
    title="Conclusive knowledge of right wall(s)" >}}
{{< /visualization >}}

More importantly, when we find a definitive right wall, it resolves not just one position but all pending positions that share the same left wall. This simultaneous resolution of multiple pending states naturally suggests a monotonic stack approach.

{{< visualization
    src="svg/trapped-water/resolution.svg"
    title="Multiple simultaneous resolution of pending states" >}}
{{< /visualization >}}

{{< section-divider >}}

## The Stack Solution

The solution organically forms around maintaining pending states:
```dart
int trapWithStack(List<int> height) {
  final List<int> stack = [];
  int totalWater = 0;

  /// test comment
  
  for (int i = 0; i < height.length; i++) {
    while (stack.isNotEmpty && height[stack.last] <= height[i]) {
      final int bottom = stack.removeLast();
      if (stack.isEmpty) break;
      
      final int distance = i - stack.last - 1;
      final int boundedHeight = 
          min(height[i], height[stack.last]) - height[bottom];
      totalWater += distance * boundedHeight;
    }
    stack.add(i);
  }
  
  return totalWater;
}
```

This achieves O(N) time complexity but requires O(N) space for the stack.

{{< section-divider >}}

## The Space Constraint Revelation

The O(1) space requirement initially feels devastating. We've built a solution from first principles, feeling confident in its correctness, only to realize it violates a core constraint. However, there is opportunity for success in failure. The lack of storage forces us to confront the only possibility left to us: if we can't store information for later resolution, we must resolve each position immediately.

Retreating to solid ground, we re-assert that the following statement must still be true:

{{< notice tip >}}
each pillar's contribution depends on three key factors:
1. Its own height
2. The height of the tallest wall to its left (left wall)
3. The height of the tallest wall to its right (right wall)
{{< /notice >}}

So if we're processing a particular i-th pillar, we absolutely need to know the height of its right-bounding wall.

This leads to an interesting thought: what if we could "cheat" by looking ahead? Surely this doesn't work otherwise we already would have adopted this solution to begin with, but our hands are tied here. We need information on the right side **now**, and out of all the positions we have yet to explore, only one of them could potentially have any hope of saying something--the last position--so let's look there!

Of course, if we are lucky, we get a situation that gives us definitive information.

{{< visualization 
    src="svg/trapped-water/two-pointer-right-higher.svg"
    title="Two-pointer technique with right wall higher than left" >}}
{{< /visualization >}}
    

But what if we're not lucky?

{{< visualization 
    src="svg/trapped-water/two-pointer-left-higher.svg"
    title="Two-pointer technique with left wall higher than right" >}}
{{< /visualization >}}

Hold on just a minute. We may not be able to say anything definitive about the pillar on the left, but what about the ones on the right? Aren't they bounded by the height of the right wall in this case? Since we have information on both sides, the asymmetry breaks down and now we can process from either side! And since there is no ambiguity at any step, we no longer need to store any information for delayed processing, allowing us to get the job done at every step of the way.

## The Optimal Solution

This realization transforms our "cheating" attempt into an elegant algorithm:

```dart
int trap(List<int> height) {
  if (height.isEmpty) return 0;
  
  int left = 0;
  int right = height.length - 1;
  int leftMax = 0;
  int rightMax = 0;
  int water = 0;
  
  while (left < right) {
    if (height[left] < height[right]) {
      if (height[left] >= leftMax) {
        leftMax = height[left];
      } else {
        water += leftMax - height[left];  // immediate processing
      }
      left++;
    } else {
      if (height[right] >= rightMax) {
        rightMax = height[right];
      } else {
        water += rightMax - height[right];  // same on the other side!
      }
      right--;
    }
  }
  
  return water;
}
```

This achieves both O(N) time complexity and O(1) space complexity, requiring only:
- Two pointer variables
- Two maximum height trackers
- Running total for water volume

## Key Insights

1. The trap of premature optimization: Our first solution, while correct, violated the space constraint
2. The value of constraint-driven thinking: The space limitation not only forced us to question our assumptions and retreat to solid logical grounds, but also guided us down very specific paths, helping with the discovery of the core insight.
3. At the end of the day, we are leveraging all the information given to us. We don't always know that a solution exists, and we don't always know how good that solution can be. So when people give us this information for free, we should make use of it.

## Learning Outcomes

1. Separating correctness from optimization in problem solving
2. Importance of constraint-driven thinking in algorithm design
3. Value of viewing constraints as guides rather than limitations
4. Power of two-pointer technique for space optimization