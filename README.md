A self-guided learning repository for implementing classic data structures and algorithms in Zig, including (currently):

- A **Stack** data structure (LIFO) with push, pop, peek, and isEmpty operations.
- A **Binary Search Tree (BST)** with a **constant-memory** freeing algorithm.



## Table of Contents

- [Getting Started](#getting-started)  
- [Stack Example](#stack-example)  
- [BST Example](#bst-example)  
  - [Constant-Memory Freeing Algorithm](#constant-memory-freeing-algorithm)  
- [Why Constant Memory?](#why-constant-memory)  
- [License](#license)  


## Getting Started

### Prerequisites

- [Zig Toolchain](https://ziglang.org/download/)

OR

- [Nix](https://nixos.org/download/) (then run `nix-shell` in repository's root folder)

### Build & Run

```bash
git clone https://github.com/bruno-maruszczak/zig-learning.git
cd zig-learning
zig build
````

To run the examples directly:

```bash
zig test src/stack.zig
zig test src/binarySearchTree.zig
```

---

## Stack Example

The stack example in `src/stack.zig` demonstrates a classic **Last-In-First-Out** structure using a singly linked list:

* **`push(item: T) !void`**
  Allocates a new node for the given item.
* **`pop() !void`**
  Removes the top item immediately freeing its node. Returns `error.StackEmpty` otherwise.
* **`peek(): ?T`**
  Returns the top item without removing it (if exists).
* **`isEmpty(): bool`**
  Returns `true` if the stack has no elements.

Notable features when we compare it to a classroom C implementation are:
- explicit use of an allocator type
- type-polymorphic definition of stack without resorting to text level macros
- semantic errors/exceptions and nullable values + syntax to handle them (`try`, `if(maybe_val)|val|{ ... }`, etc.)


## BST Example

The BST example in `src/binarySearchTree.zig` implements:

* **`insert(self: *Self, newValue: T)`**
  Standard binary-search–tree insertion.
* **`deinit(self: *Self)`**
  A special freeing routine that uses **O(1)** extra memory (no recursion or auxiliary stack).

### Constant-Memory Freeing Algorithm

Normally, freeing a tree via post-order recursion or an explicit stack uses **O(d)** auxiliary memory (where *d* is the tree depth). Here, we employ a variant of **Morris tree traversal**. Because we don't need to restore the tree we instead mutate the tree into a linked list and free the tree iterating from flattened tree's leaf to root achieving O(1) memory and O(n) runtime compexity. 

Ironically, the debug printing routine uses regular recursive tree traversal which could also be replaced by constant memory footprint routine.

## Why Constant Memory?

Algorithms that require **O(1)** auxiliary memory are vital when resources are tight:

* **Embedded Devices**
  Microcontrollers and IoT nodes often have only a few kilobytes of RAM. Avoiding recursion or large stacks prevents overflows and out-of-memory faults.
* **Microservices & Serverless**
  Each container or function instance benefits from a minimal memory footprint—lower overhead translates to reduced costs and better scalability.
* **Real-Time & Safety-Critical Systems**
  Predictable, bounded memory use helps guarantee consistent performance and simplifies certification against strict timing constraints.
