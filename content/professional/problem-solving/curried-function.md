---
title: "Understanding Curried Functions: Journey to an Intuitive Mental Model"
date: 2024-03-15
lastmod: 2024-03-15
draft: false
description: "An exploration of curried functions in JavaScript, comparing them to recursion, and developing an elegant mental model for understanding this powerful functional programming concept."
tags: ["functional-programming", "javascript", "currying", "closures", "mental-models"]
categories: ["programming-concepts"]
series: ["functional-programming-patterns"]
slug: "curried-functions"
math: false
toc: true
readingTime: 12
---

## Problem Statement

Write a function, `add_subtract`, which alternately adds and subtracts curried arguments. Here are some sample operations:

```javascript
add_subtract(7) -> 7

add_subtract(1)(2)(3) -> 1 + 2 - 3 -> 0

add_subtract(-5)(10)(3)(9) -> -5 + 10 - 3 + 9 -> 11
```

What makes this challenge interesting isn't just the computation it performs, but the unusual syntax it uses. Those chains of parentheses represent a powerful programming concept called **currying**.

## Initial Analysis

When I first encountered curried functions, I was baffled. The syntax looked like a mistake - as if someone had forgotten how function calls work. But if it's not a mistake, what exactly is happening here?

Let's break down what's actually happening in these function calls:

```javascript
add_subtract(5)    // Returns a function
add_subtract(5)(3) // Calls that returned function with 3, which returns another function
add_subtract(5)(3)(2) // And so on...
```

The syntax `f(x)(y)` means: 
1. First, execute `f(x)` which returns a function
2. Then, immediately invoke that returned function with the argument `y`

This chain can continue indefinitely, with each call returning a new function ready to accept the next argument.

Now that we understand what's being asked of us, how do we go about producing this behavior?

## Building a Mental Model

### Simple Currying Example

Let's start with a comparison to help understand the concept:

```javascript
// Regular function
function add(a, b) {
  return a + b;
}

// Curried version
function curriedAdd(a) {
  return function(b) {
    return a + b;
  }
}

// Both return 3
console.log(add(1, 2));
console.log(curriedAdd(1)(2));
```

The regular function processes all arguments at once, while the curried version takes them one at a time, creating a chain of nested functions.

There's something remarkable happening here that might not be immediately obvious. The inner function somehow "remembers" the value of `a` even after the outer function has completed. This is a key mechanism called closure.

### The Magic of Closures

The key to making curried functions work is closure scope. When the inner function is created, it "captures" the value of `a` from its enclosing scope:

```javascript
function curriedAdd(a) {
  // 'a' is stored in closure scope
  return function(b) {
    // Can still access 'a' here
    return a + b;
  }
}

let add1 = curriedAdd(1); // 'a' is now 1 in the closure
console.log(add1(2));     // 3 (1 + 2)
console.log(add1(5));     // 6 (1 + 5)
```

The inner function maintains access to `a` even after `curriedAdd` has finished executing. Each time we call `curriedAdd` with a different value, we get a new function with its own persistent reference to that specific value of `a`.

### Extending to Multiple Arguments

The next logical step is to extend our function to handle more than two arguments:

```javascript
function curriedAdd(a) {
  return function(b) {
    return function(c) {
      return a + b + c;
    }
  }
}

// Usage
console.log(curriedAdd(1)(2)(3)); // 6
```

This works, but it has a significant limitation - we've hardcoded exactly three nested functions. This approach would only work when we know exactly how many arguments we need to process.

To make progress toward our goal of an alternate adding and subtracting function that can handle any number of arguments, we need to restructure our approach. Let's start by modifying our three-argument function to use a running state:

```javascript
function curriedSum(first) {
  let sum = first; // Initialize state in the outermost function
  
  function addSecond(second) {
    // Update the shared state with the second argument
    sum += second; 
    
    function addThird(third) {
      // The innermost function still has access to the same 'sum' variable
      // Each function in the chain can read and modify this shared state
      sum += third; 
      return sum;   // Finally return the accumulated sum
    }
    
    return addThird;
  }
  
  return addSecond;
}

// Usage
console.log(curriedSum(1)(2)(3)); // 6

// We could also use intermediate variables to see how state progresses:
let afterFirst = curriedSum(1);    // sum is 1 internally
let afterSecond = afterFirst(2);   // sum is 3 internally
let finalResult = afterSecond(3);  // sum is 6, and returned
console.log(finalResult);          // 6
```

Notice how the `sum` variable is defined once in the outer function, but updated at each layer. Through the power of closures, each nested function has access to the same `sum` variable and can both read and modify it. The state is propagated through the chain, with each function call adding to the running total.

This approach differs from our first three-argument function. In the original version (`curriedAdd`), each argument was stored separately and only combined in the final calculation. In this new version (`curriedSum`), we maintain a running total that's updated with each call.

This approach allows us to perform null checks for the subsequent arguments and thus support **up to** being called 3 times, instead of strictly 3 times.

But we still have a problem: what if we want to handle four arguments? Or five? We'd need to manually add more nested functions for each additional argument we want to support. The depth is hardcoded into the structure of our function.

Looking at our current implementation, we can observe a pattern. Each nested function:
1. Takes the next argument
2. Updates the shared state
3. Defines a function that uses that shared state
4. Returns that function 

Is there a way to avoid manually nesting these nearly identical operations?

### The Self-Returning Pattern

Instead of manually nesting these nearly identical functions, what if we had a single function that just kept returning itself? Let's try that approach:

```javascript
function curriedSum(first) {
  let sum = first; // Initialize state
  
  function addMore(next) {
    sum += next;   // Update state with each call
    return addMore; // Return ITSELF for chaining
  }
  
  return addMore;
}

// Usage
let runner = curriedSum(1);
runner = runner(2);  // sum is now 3
runner = runner(3);  // sum is now 6
runner = runner(4);  // sum is now 10

// Or more concisely:
curriedSum(1)(2)(3)(4)(5); // Can be chained indefinitely
```

This is a breakthrough! Instead of hardcoded nesting, we now have a function that can accept any number of arguments through continued chaining. Each call updates the state and returns the same function for the next call.

This pattern feels reminiscent of recursion, where a function calls itself. But is this really recursive? Let's examine the parallel more closely.

## The Recursion Parallel

While developing this solution, I noticed an interesting parallel between curried functions and recursion. Both involve a function that either directly or indirectly references itself, creating a repeating pattern, as well as a "helper wrapper" function that kick starts the process, enabling the self-generating property.

Let's compare the patterns directly:

```
Recursive Pattern            |  Curried Pattern
-----------------------------|---------------------------
function recurse(n) {        |  function curry(first) {
  if (n <= 1) return 1;      |    let current = first;
  return recurse(n-1) * n;   |    function calc(next) {
}                            |      current += next;
                             |      return calc;
                             |    }
                             |    return calc;
                             |  }
```

We can see the `recurse` function calling itself with a different argument, similar to how the `calc` function returns itself to be invoked with a different argument.

But these patterns differ significantly in their execution flow.

### Outside-In vs. Inside-Out Processing

With recursion, operations must wait for deeper calls to complete before continuing:

**With recursion (Inside-Out):**
- Operations are SUSPENDED while waiting for deeper calls to complete
- Memory usage grows with recursion depth
- Work happens from the innermost call outward (deepest call resolves first, then bubbles up)

```
factorial(3)
├── factorial(2) [suspended]
│   ├── factorial(1) → returns 1
│   └── resumes → returns 2
└── resumes → returns 6
```

**With currying (Outside-In):**
- Each step completes IMMEDIATELY and returns a function
- State is preserved in closures, not the call stack
- Work happens from the outermost call inward (each step transforms the state as it occurs)

```
curriedSum(1)
└── updates state: sum = 1
└── returns addMore function
   └── curriedSum(1)(2)
      └── updates state: sum = 3
      └── returns addMore function
         └── curriedSum(1)(2)(3)
            └── updates state: sum = 6
            └── returns addMore function
```

This fundamental difference has significant implications. Since curried functions process "outside-in," they can do partial work without waiting for all arguments. They can immediately process the arguments they have and remain ready for more. Recursive functions, in contrast, must reach their base case before any work completes.

This is the second key difference: Termination conditions

**With recursion:**
- Termination is built into the function itself
- The function identifies when it has reached a "base case"
- The chain resolves automatically once this condition is met

**With currying:**
- Termination typically relies on an external signal
- The chain continues as long as someone keeps invoking returned functions
- Termination happens when the external context stops calling functions or sends a specific signal (like our empty call)

## Solving the Add-Subtract Challenge

Now that we understand the self-returning pattern, let's apply it to our original challenge. We need a function that:
1. Keeps track of a running result
2. Alternates between adding and subtracting
3. Can handle any number of arguments
4. Returns the final result when needed

All we need to add to our understanding is a mechanism for alternating between addition and subtraction. We already know how to maintain and update states between calls, so this is a trivial matter of declaring, maintaining, updating a boolean flag.

Here's our solution:

```javascript
function add_subtract(first) {
  let result = first;
  let addNext = true; // Start with addition
  
  function compute(next) {
    if (next === undefined) {
      return result; // Return the final result when called with no arguments
    }
    
    // State updates
    // 1. Update the sum 
    if (addNext) {
      result += next;
    } else {
      result -= next;
    }
    // 2. Update the flag
    addNext = !addNext;

    return compute; // Return itself for chaining
  }
  
  return compute;
}

// Usage
console.log(add_subtract(1)(2)(3)()); // 1 + 2 - 3 = 0
console.log(add_subtract(-5)(10)(3)(9)()); // -5 + 10 - 3 + 9 = 11
```

Let's examine what makes this work:

1. **State Maintenance**: The variables `result` and `addNext` persist in the closure scope
2. **Self-Returning Pattern**: The key insight is in the return statement: `return compute` - the function returns itself
3. **Termination Mechanism**: An empty call `()` serves as the signal to stop and return the result
4. **Behavior Toggling**: The `addNext` boolean alternates the operation between addition and subtraction

The beauty of this solution is its flexibility - it can handle any number of arguments without hardcoding nested functions. Each call transforms the state and returns the same function ready for the next call.

### The Type Constraint Challenge

Notice some details that we glossed over earlier:
```javascript
// Usage
console.log(add_subtract(1)(2)(3)()); // 1 + 2 - 3 = 0
console.log(add_subtract(-5)(10)(3)(9)()); // -5 + 10 - 3 + 9 = 11
```

Here we explicitly call `f()` when we wish to retrieve the value instead of performing more operations. This is a necessity given the design we made, but it doesn't match the problem requirements which had no final empty calls.

Recall:
```javascript
add_subtract(1)(2)(3) -> 1 + 2 - 3 -> 0
```
So how do we fix this?

In our solution, our function needs to do two different things: sometimes return a function (for chaining) and sometimes return a value (for the final result). In JavaScript, this actually works fine because the language is loosely typed - a function can return different types without issue. One additional quirk of Javascript is that a function can both be called or evaluated to its final value if not called, so returning the function as a single type is sufficient for both uses:

```javascript
f(5); // ---> f is understood as a function being called
print(f); // ---> f === the value that f would evaluate to if called
```

Javascript has its quirks because it's meant to be used for the web and we want as little disruptive problems as possible, so we overlook these kinds of things. In a stricter language, this does not fly.

### Implementation in Stricter Type Systems

What do we do then in languages with stricter type systems, like Dart? In such environments, a function generally must declare a consistent return type. There are two main approaches to solve this:

1. **Using an empty call for termination** (as we did above): This approach requires us to declare the return type as `dynamic` so that we can sometimes return a `Function` and sometimes return an `int`
2. **Creating a wrapper class that's both callable and provides access to its state**: This feels more in line with the requirements because we never see empty calls. The only compromise we make is that we have to "peek" at the current value by accessing it via a getter.

Let's look at the second approach using Dart:

```dart
class Computation {
  num _result;
  bool _addNext;
  
  Computation(this._result) : _addNext = true;
  
  // Make the class callable
  dynamic call([dynamic next]) {
    if (next == null) {
      return _result;
    }
    
    if (_addNext) {
      _result += next;
    } else {
      _result -= next;
    }
    
    _addNext = !_addNext;
    return this;
  }
  
  // Override toString to get string representation
  @override
  String toString() => _result.toString();
  
  // Helper to convert to num
  num get value => _result;
}

Computation add_subtract(dynamic first) => Computation(first is num ? first : 0);
```

This Dart implementation uses a class with a `call()` method, which makes instances of the class callable like functions. The class also provides direct access to its internal state through the `value` getter property.

This approach reveals an interesting insight: in languages with stricter type systems, object-oriented techniques can help implement functional patterns. The class encapsulates state while providing callable behavior, effectively bridging the gap between paradigms.

## Practical Applications

Now that we've explored curried functions in depth, let's look at how they can be useful in everyday programming:

1. **Partial Application**: Create specialized functions by fixing some arguments
   ```javascript
   // Create a family of adder functions
   const add5 = curriedAdd(5);
   const add10 = curriedAdd(10);
   
   // Use them later with different second arguments
   console.log(add5(3));  // 8
   console.log(add10(3)); // 13
   ```

2. **Function Composition**: Build complex operations from simple parts
   ```javascript
   const double = x => x * 2;
   const add3 = x => x + 3;
   
   // With currying and composition helpers
   const compose = f => g => x => f(g(x));
   const doubleThenAdd3 = compose(add3)(double);
   ```

3. **Data Transformation Pipelines**: Process data through a series of steps
   ```javascript
   const processData = data => validate(data)(transform)(format)(display);
   
   // Each step returns a function that accepts the next processor
   // This creates readable, sequential processing chains
   ```

## Key Insights

The journey to understanding curried functions reveals several important insights:

1. **Outside-In Processing**: Curried functions work from the outermost call inward, unlike recursion's inside-out approach
2. **State Preservation**: Closures maintain state between function calls without relying on the call stack
3. **Immediate vs. Suspended Execution**: Each step in a curried chain completes immediately, while recursive calls suspend until resolution
4. **Language Implementation Variations**: Different languages require different approaches to implement the same pattern
5. **Paradigm Connections**: Functional patterns like currying have analogues in object-oriented programming

The recursion parallel is useful for understanding the self-perpetuating nature of curried functions. It bridges a familiar concept and makes the new one immediately accessible once we replace "return value" with "return function that can be invoked." With proper examination of the outside-in nature of currying, we can extend from that parallel to arrive at a complete understanding.