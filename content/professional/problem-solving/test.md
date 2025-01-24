---
title: "test"
date: 2024-01-23
lastmod: 2024-01-23
draft: false
description: "An in-depth development of monotonic stack technique and further optimization"
tags: ["algorithms", "monotonic-stack", "two-pointer", "problem-solving"]
categories: ["problem-solving"]
series: ["algorithm-deep-dives"]
math: true
toc: true
---

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