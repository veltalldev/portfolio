---
title: "Journey to Solving the Coin Change Problem"
date: 2024-01-22
lastmod: 2024-01-22
draft: false
description: "An exploration of dynamic programming and greedy approaches to the classic coin change problem, with insights into proof development and algorithm optimization."
tags: ["algorithms", "dynamic-programming", "greedy-algorithms", "problem-solving"]
categories: ["problem-solving"]
series: ["algorithm-deep-dives"]
slug: "coin-change"
math: true
toc: true
readingTime: 15
---


## Problem Statement

Given US coin denominations (1¢, 5¢, 10¢, 25¢), find the minimum number of coins required to make n cents.

{{< notice info >}}
**Key Challenge**: While dynamic programming provides a general solution, the specific properties of US coin denominations enable a more efficient greedy approach.
{{< /notice >}}

## Phase 1: Dynamic Programming Foundation

### Initial Analysis
My first approach leveraged dynamic programming as a reliable foundation. The key observations that guided this choice:

- The problem exhibits optimal substructure - optimal solutions for larger amounts build upon optimal solutions for smaller amounts
- We only need to store the count of coins, not the combinations
- A 1D DP array would suffice for space optimization

### DP Solution Characteristics
The dynamic programming solution offered several advantages:

```python
def coinChange(coins: List[int], amount: int) -> int:
    dp = [float('inf')] * (amount + 1)
    dp[0] = 0
    
    for coin in coins:
        for x in range(coin, amount + 1):
            dp[x] = min(dp[x], dp[x - coin] + 1)
    
    return dp[amount] if dp[amount] != float('inf') else -1
```

Key characteristics:
- **Time Complexity**: {{< math "O(n \cdot m)" >}} where n is target amount, m is number of denominations
- **Space Complexity**: {{< math "O(n)" >}}
- **State Transition**: {{< math block="true" tex="dp[i] = \min(dp[i], 1 + dp[i - coin])" >}} for each coin
- **Flexibility**: Works for any denomination system

## Phase 2: Exploring the Greedy Approach

The journey took an interesting turn when I began exploring whether a greedy approach might be viable specifically for US denominations.

### Intuition Development
1. Initial observation suggested that always taking the largest possible denomination might be optimal
2. Started exploring why this intuition might be true
3. First attempts focused on proving it would never be beneficial to exceed larger denominations

### Evolution of the Proof
The proof development process itself revealed valuable insights about approaching algorithm verification:

**First Attempt**: Tried to prove you can't exceed larger denominations
  - Too strong a condition
  - Unnecessary for optimality
  - Led to dead ends

**Second Attempt**: Shifted focus to exact denomination matching
  - More promising direction
  - Focused on comparing coin counts between greedy and non-greedy approaches
  - Still missing key insights

**Key Breakthrough**: Identified the critical property
   - Exact reproducibility of larger denominations
   - Proved that matching exactly always requires at least 2 smaller coins
   - This was the crucial insight that unlocked the proof

### Final Proof Structure

The final proof came together with two key components:

{{< proof type="lemma" name="Denomination Reproducibility" >}}
For the US coin denomination system (1¢, 5¢, 10¢, 25¢), any sum that exceeds a larger denomination can be transformed into an exact match using the same or fewer coins.

**Proof of cases:**
1. For 25¢: Any sum > 25¢ made with smaller coins requires at least 3 coins (as 20¢ is max with two coins). We can reach 25¢ with 3 coins: 10¢, 10¢, and 5¢.
2. For 10¢: Any sum > 10¢ requires at least 2 coins of 5¢ or more of 1¢
3. For 5¢: Any sum > 5¢ up to 9¢ requires at least 5 coins of 1¢
{{< /proof >}}

{{< proof type="theorem" name="Greedy Optimality" >}}
The greedy algorithm of selecting the largest possible coin at each step produces the optimal (minimum) number of coins needed for any sum using US coin denominations.
{{< /proof >}}

{{< proof name="Greedy Optimality" method="contradiction" >}}
Suppose there exists a non-greedy solution S that uses fewer coins than the greedy solution G. Then:

1. S must use more smaller coins in place of some larger coin
2. By the Denomination Reproducibility Lemma, this substitution always requires more coins to produce the same partial sum
3. Additionally, the surplus amount in each solution must be the same amount, and therefore the same number of coins at worst
4. Therefore S must use more coins than G, contradicting our assumption
4. Thus, no such better solution S can exist
{{< /proof >}}

## Key Insights

This journey yielded several valuable insights about problem-solving and proof development:

{{< notice tip >}}
**Core Insight**: The key to proving greedy optimality wasn't showing that exceeding denominations was impossible, but rather that it was always inefficient. This inefficiency lies in the ability to construct exactly that denomination, but with at least 2 coins.
{{< /notice >}}

**Separation of Concerns**
  - Distinguishing correctness from optimality
  - Breaking complex proofs into manageable lemmas

**Property Selection**
   - Finding the right property to prove is often more crucial than the proof itself
   - Exact matching vs. impossibility of exceeding was a key pivot

**Generalization vs. Specialization**
   - Understanding when to use specific properties (US denominations)
   - Maintaining awareness of generality where possible

## Broader Implications

The techniques developed here extend beyond this specific problem. The proof approach provides insight into what makes a denomination system "greedy-compatible":

- The ability to exactly reproduce larger denominations with smaller ones, and by extension:
- Guaranteed inefficiency of such reproduction compared to using larger denominations directly

Beyond being applicable to determining "greedy-compatibility" in other denomination systems, the lesson learned here can hopefully be carried forward to other greedy proofs: reduce non-greedy configuration to greedy ones while seeking inefficiency.

## Learning Outcomes

**Proof Development Strategy**
   - Start with stronger conditions and relax as needed
   - Look for key properties that enable simpler proofs
   - Use supporting lemmas to handle technical requirements

**Algorithm Design Philosophy**
   - Begin with reliable approaches (DP)
   - Explore optimizations based on specific constraints
   - Balance generality with optimization opportunities

**Problem-Solving Methodology**
   - Systematic exploration of solution space
   - Iterative refinement of proofs and approaches
   - Clear documentation of thinking process