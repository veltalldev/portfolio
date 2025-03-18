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

// Both return the same result: 3
console.log(add(1, 2));         // Traditional: f(x,y)
console.log(curriedAdd(1)(2));  // Curried: f(x)(y)
```

The regular function processes all arguments at once, while the curried version takes them one at a time, creating a chain of nested functions.

There's something remarkable happening here that might not be immediately obvious. The inner function somehow "remembers" the value of `a` even after the outer function has completed. This is a key mechanism called closure.

### The Magic of Closures

There is something that makes enough sense to be glossed over at first glance here, but let's take a closer look. When we call `curriedAdd(1)`, the return value is defined as:

```javascript
return function(b) {
  return a + b;
}
```

Is it not strange that `a` is referenced here, even though the outer function has already completed? The inner function maintains access to `a` even after `curriedAdd` has finished executing. This invisible connection to variables from the creation context is what we call a closure.

```javascript
function curriedAdd(a) {
  return function(b) {
    return a + b;  // How does this inner function still have access to 'a'?
  }
}

const add5 = curriedAdd(5);
console.log(add5(3));  // 8
console.log(add5(10)); // 15
```

I like to visualize this as the function carrying an invisible "backpack" of variables from its creation context.

```javascript
// What's happening behind the scenes
const add5 = function(b) {
  // Invisible backpack: { a: 5 }
  return 5 + b;
}
```

This is what makes currying possible - each function in the chain carries its own backpack of variables from its creation context.

### Extending to Multiple Arguments

Let's extend our function to handle three arguments:

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

// We can also capture intermediate functions
const add1 = curriedAdd(1);
const add1and2 = add1(2);
const result = add1and2(3);
console.log(result); // 6
```

This works, but it has a significant limitation - we've hardcoded exactly three nested functions. This approach only works when we know exactly how many arguments we need to process.

To make our function more flexible, we could add optional argument handling. This allows us to use `curriedSum` with **up to** 3 variables:

```javascript
function curriedSum(first) {
  let sum = first;
  
  function addNext(second) {
    if (second === undefined) return sum;
    sum += second; 
    
    function addThird(third) {
      if (third === undefined) return sum;
      sum += third; 
      return sum;
    }
    
    return addThird;
  }
  
  return addNext;
}

// Usage
console.log(curriedSum(1)(2)(3));  // 6
console.log(curriedSum(1)(2)());   // 3 (stops after two arguments)
```

Notice how the `sum` variable is defined once in the outer function, but updated at each layer. Through the power of closures, each nested function has access to the same `sum` variable and can both read and modify it.

But we still have a problem: what if we want to handle four arguments? Or five? We're still limited by the number of functions we manually nest. It is immediately obvious that sitting here typing out 10,000 layers of nesting is not the best use of anyone's time.

### The Self-Returning Pattern

Instead of manually nesting similar functions, what if we had a single function that just kept returning itself? Consider:

```javascript
function curriedSum(first) {
  let sum = first; // Initialize state
  
  function addMore(next) {
    if (next === undefined) {
      return sum; // Return the result if no argument is provided
    }
    
    sum += next;   // Update state with each call
    return addMore; // Return ITSELF for chaining
  }
  
  return addMore;
}

// Usage showing the progression of state
let step1 = curriedSum(1);         // sum is 1 internally
console.log(step1());              // 1

let step2 = step1(2);              // sum is now 3
console.log(step2());              // 3

let step3 = step2(3);              // sum is now 6
console.log(step3());              // 6

// Or more concisely:
console.log(curriedSum(1)(2)(3)()); // 6
```

This is a breakthrough! Instead of hardcoded nesting, we now have a function that can accept any number of arguments through continued chaining. Each call returns the same function for the next call, but it also updates the shared state so each new call gets effectively a new "input". 

`[same behavior]` + `[new data]` = `[new behavior]`

An important detail to note: unlike our nested approach where each function has its own closure, the self-returning pattern maintains state in a single shared closure that gets updated with each call. It's like having a single "backpack" whose contents change with each invocation, rather than creating a new backpack each time. As long as a closure still exists that references the variables, they will continue to be kept in memory.

## The Recursion Parallel

While developing this solution, I noticed an interesting parallel between curried functions and recursion. Both involve a function that either directly or indirectly references itself, creating a "blind" repeating pattern. They also involve a "helper wrapper" function that kick starts the process to enable the self-generating property.

In both cases, we are unable to examine "ahead" to understand the arguments we are working with--not even their quantity. We have to design a process that blindly accepts new calls so long as new calls are possible.

Let's compare the patterns directly:

```javascript
// Recursive pattern
function factorial(n) {
  // ...
  return n * factorial(n - 1); // Calls itself
}

// Self-returning curried pattern
function compute(next) {
  // ...
  return compute; // Returns itself
}
```

Note the difference: the existence of the parentheses in `factorial()` indicates that we are invoking the function right then and there, whereas the return statement `return compute` without parentheses means we are simply returning the function. Its invocation is determined by whoever on the outside is receiving it.

### Outside-In vs. Inside-Out Processing

As we were discussing, the key difference is in how these patterns process their operations:

**With recursion (Inside-Out):**
- Operations are SUSPENDED while waiting for deeper calls to complete
- Memory usage grows with recursion depth (call stack)
- Work happens from the innermost call outward (deepest call resolves first)

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
└── returns compute function
   └── curriedSum(1)(2)
      └── updates state: sum = 3
      └── returns compute function
         └── curriedSum(1)(2)(3)
            └── updates state: sum = 6
            └── returns compute function
            └── curriedSum(1)(2)(3)()
               └── returns state: 6
```

This is a crucial distinction. In recursion, we must wait for all nested calls to complete before any work is done. In currying, each step processes immediately, updating the state and returning a new function that's ready for the next call.

### Termination Conditions

A related key difference between recursion and currying is how they terminate:

**With recursion:**
- Termination is built into the function itself (base case)
- The function identifies when it has reached its conclusion
- The chain resolves automatically once this condition is met

**With currying:**
- Termination typically relies on an external signal
- The chain continues as long as someone keeps invoking returned functions
- Termination happens when the caller stops the chain or sends a specific signal


## Solving the Add-Subtract Challenge

Now that we have a grasp on the self-returning pattern, let's apply it to our original challenge. We need a function that:
1. Keeps track of a running result
2. Alternates between adding and subtracting
3. Can handle any number of arguments
4. Returns the final result when needed

All we need to add to our current understanding is a mechanism for alternating between addition and subtraction. We already know how to maintain and update states between calls, so this is a trivial matter of declaring, maintaining, and updating a boolean flag.

Here's our solution:

```javascript
function add_subtract(first) {
  // Declare states in closure
  let result = first;
  let addNext = true;
  
  function compute(next) {
    if (next === undefined) {
      return result; // Return the result when called with no arguments
    }
    
    // Update state 1: sum
    if (addNext) {
      result += next;
    } else {
      result -= next;
    }
    // Update state 2: flag
    addNext = !addNext;
    
    // Return itself for chaining
    return compute;
  }
  
  return compute;
}

// Usage with explicit termination
console.log(add_subtract(1)(2)(3)()); // 1 + 2 - 3 = 0
console.log(add_subtract(-5)(10)(3)(9)()); // -5 + 10 - 3 + 9 = 11
```

Let's examine what makes this work:

1. **State Maintenance**: The variables `result` and `addNext` persist in the closure
2. **Self-Returning Pattern**: The function returns itself with `return compute`
3. **Termination Mechanism**: An empty call `f()` signals to stop and return the result
4. **Behavior Toggling**: The `addNext` boolean alternates between addition and subtraction

### The Termination Challenge

Notice some details that we glossed over earlier:
```javascript
// Usage
console.log(add_subtract(1)(2)(3)()); // 1 + 2 - 3 = 0
console.log(add_subtract(-5)(10)(3)(9)()); // -5 + 10 - 3 + 9 = 11
```

Here we explicitly call `f()` when we wish to retrieve the value instead of performing more operations. This is a necessity because a curried function **always** returns a function, but it doesn't match the problem requirements which had no final empty calls.

Recall:
```javascript
add_subtract(1)(2)(3) -> 1 + 2 - 3 -> 0
```
So how do we fix this?

In our solution, our function needs to do two different things: sometimes return a function (for chaining) and sometimes return a value. This is **impossible** for naturally obvious reasons.

The desired behavior needs a workaround, and the specific details of that workaround depends on the language being used.

#### JavaScript Conveniences
Due to its web environment, JavaScript was designed to fail as little as possible, which leads to the highly comical behaviors that make it famous. One of those quirks is something we can leverage to mock the behavior we desire: `valueOf` and `toString` hooks.

```javascript
function add_subtract(first) {
  // ...

  // Add conversion methods to make the function behave like a value
  compute.valueOf = function() {
    return result; // For numeric contexts
  };
  
  compute.toString = function() {
    return result.toString(); // For string contexts
  };
  
  return compute;
}

// Now these work without empty calls
console.log(+add_subtract(1)(2)(3)); // 0 (+ forces numeric conversion)
console.log(add_subtract(1)(2)(3) + ""); // "0" (string concatenation forces toString)
console.log(`Result: ${add_subtract(1)(2)(3)}`); // "Result: 0" (template literal forces toString)
```

By adding `valueOf()` and `toString()` methods to our returned function, we make it behave like a value in contexts that expect one. This is a JavaScript-specific technique that takes advantage of the language's automatic type conversion.

#### Implementation in Stricter Type Systems

What do we do then in languages with stricter type systems, like Dart? In such environments, a function generally must declare a consistent return type and stick to that type. There are two main approaches to solve this:

1. **Using an empty call for termination** (as we did above): This approach requires us to declare the return type as `dynamic` so that we can sometimes return a `Function` and sometimes return an `int`. This is the fundamental way to use curried functions and is the default choice for every language.
2. **Creating a wrapper class that's both callable and provides access to its state**: This approach is more in line with the requirements of never seeing empty calls. The only compromise we make is that we have to "peek" at the current value by accessing it via a getter.

Let's look at a Dart implementation using the second approach:

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

Computation add_subtract(num first) => Computation(first);

// Usage:
final calc = add_subtract(1)(2)(3);
print(calc.value); // 0
print(calc); // 0
```

This Dart implementation uses a class with a `call()` method, which makes instances of the class callable like functions. The class also provides direct access to its internal state through the `value` getter property.

This approach reveals an interesting insight: in languages with stricter type systems, object-oriented techniques can help implement functional patterns. The class encapsulates state while providing callable behavior, effectively mirroring the behavior of a functional closure and bridging the gap between paradigms.

#### Key Takeaway

The general idea is this:
- The fundamental facts of reality creates a divergence between how the curried function presents itself and how we expect it, i.e. as a **function** vs as a **value AND a function**
- In order to achieve the flexibility that we want, we need to anticipate every context where the returned value is expected to behave like a value, then provide the workaround for that context. As an example, the two most prominent ways in which we interact with the value is:
  - Looking at it via print statements
  - Using it in computations
- Both of these behaviors (and possibly more) can be mocked with some workaround, but it is important to recognize that every language must do so with varying degrees of effort.

## Practical Applications

Now that we've explored curried functions in depth, let's look at some practical applications:

### 1. Partial Application

Create specialized functions by fixing some arguments:

```javascript
const add = a => b => a + b;

// Create specialized adders
const add5 = add(5);
const add10 = add(10);

// Use them with different values
console.log(add5(3));  // 8
console.log(add5(7));  // 12
console.log(add10(3)); // 13
```

This technique is useful for creating families of related functions that share common behavior but differ in some specific parameter.

### 2. Function Composition

Build complex operations from simple parts:

```javascript
const compose = f => g => x => f(g(x));

const double = x => x * 2;
const add3 = x => x + 3;

// Combine functions
const doubleThenAdd3 = compose(add3)(double);
const add3ThenDouble = compose(double)(add3);

console.log(doubleThenAdd3(5)); // (5 * 2) + 3 = 13
console.log(add3ThenDouble(5)); // (5 + 3) * 2 = 16
```

This allows for the construction of complex operations from simple, reusable parts.

### 3. API Configuration

Create flexible, configurable API clients:

```javascript
const api = baseUrl => endpoint => params => 
  fetch(`${baseUrl}${endpoint}?${new URLSearchParams(params)}`);

// Configure the API client for different services
const myApi = api('https://example.com');
const usersEndpoint = myApi('/users');

// Use with specific parameters
usersEndpoint({page: 1}).then(response => response.json());
usersEndpoint({page: 2}).then(response => response.json());
```

This pattern creates a clean, readable way to configure and use API clients with different settings.

### 4. Data Transformation Pipelines

Process data through a series of steps:

```javascript
const process = validate => transform => format => display => data => {
  const validated = validate(data);
  const transformed = transform(validated);
  const formatted = format(transformed);
  return display(formatted);
};

// Configure a specific pipeline
const processUserData = process(validateUser)(transformUser)(formatUser)(displayUser);

// Use it with different data sets
processUserData(userData1);
processUserData(userData2);
```

This creates readable, sequential processing chains that can be configured for different scenarios.

## Key Insights

The journey to understanding curried functions reveals several important insights:

1. **Outside-In Processing**: Curried functions work from the outermost call inward, unlike recursion's inside-out approach
2. **State Preservation**: Closures maintain state between function calls without relying on the call stack
3. **Immediate vs. Suspended Execution**: Each step in a curried chain completes immediately, while recursive calls suspend until resolution
4. **Language Implementation Variations**: Different languages require different approaches to implement the same pattern
5. **Paradigm Connections**: Functional patterns like currying have analogues in object-oriented programming

The recursion parallel is useful for understanding the self-perpetuating nature of curried functions. It bridges a familiar concept and makes the new one immediately accessible once we replace "return value" with "return function that can be invoked." With proper examination of the outside-in nature of currying, we can extend from that parallel to arrive at a complete understanding.