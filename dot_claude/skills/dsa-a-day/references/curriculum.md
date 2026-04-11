# DSA Curriculum — Front-End Focused

Progression map for daily DSA practice. Each topic includes front-end relevance,
typical problem count to feel comfortable, and prerequisites.

---

## Foundation (Weeks 1–3)

### Arrays & Strings
- **Description**: Traversal, manipulation, in-place operations, subarrays
- **Front-end relevance**: List rendering, filtering, transforming API responses, DOM node lists

- **Prerequisites**: none

### Hash Maps & Sets
- **Description**: Frequency counting, lookups, deduplication, grouping
- **Front-end relevance**: Caching, memoization, event deduplication, state normalization (Redux entities)

- **Prerequisites**: arrays

### Stacks & Queues
- **Description**: LIFO/FIFO patterns, monotonic stacks, bracket matching
- **Front-end relevance**: Undo/redo, browser history, event queues, middleware chains

- **Prerequisites**: arrays

---

## Core Patterns (Weeks 3–6)

### Two Pointers
- **Description**: Converging pointers, fast/slow, partitioning
- **Front-end relevance**: Sorted list operations, intersection observers, range selection

- **Prerequisites**: arrays

### Sliding Window
- **Description**: Fixed and variable window, shrink/expand pattern
- **Front-end relevance**: Throttling/debouncing, virtualized lists, streaming data windows

- **Prerequisites**: arrays, hash-maps

### Recursion & Backtracking
- **Description**: Base cases, recursive decomposition, pruning, memoization
- **Front-end relevance**: Component tree traversal, nested menu rendering, form validation trees

- **Prerequisites**: stacks

### Sorting
- **Description**: Comparison sorts, counting sort, sort stability, custom comparators
- **Front-end relevance**: Table sorting, search result ranking, priority rendering

- **Prerequisites**: arrays, two-pointers

---

## Intermediate (Weeks 6–10)

### Linked Lists
- **Description**: Traversal, reversal, cycle detection, merge
- **Front-end relevance**: Event listener chains, middleware, undo history (doubly linked)

- **Prerequisites**: two-pointers, recursion

### Trees & BST
- **Description**: Traversals (pre/in/post/level), BST operations, tree construction
- **Front-end relevance**: DOM tree, component hierarchy, virtual DOM diffing, accessibility trees

- **Prerequisites**: recursion, stacks

### Binary Search
- **Description**: Search space reduction, boundary finding, rotated arrays
- **Front-end relevance**: Bisecting scroll positions, finding breakpoints, version comparisons

- **Prerequisites**: arrays, sorting

### BFS & DFS
- **Description**: Graph/tree traversal, level-order, connected components
- **Front-end relevance**: DOM traversal, dependency resolution, route discovery, component tree walking

- **Prerequisites**: trees, stacks, queues

---

## Applied (Weeks 10+)

### Dynamic Programming (Basics)
- **Description**: Overlapping subproblems, optimal substructure, tabulation vs memoization
- **Front-end relevance**: Memoized selectors, computed property caching, diff algorithms

- **Prerequisites**: recursion, arrays

### Heaps / Priority Queues
- **Description**: Min/max heap, top-K problems, merge K sorted
- **Front-end relevance**: Task scheduling, notification priority, rate limiting

- **Prerequisites**: arrays, trees

### Graphs (Basics)
- **Description**: Adjacency list/matrix, shortest path, topological sort
- **Front-end relevance**: Dependency graphs (webpack/vite), state machines, route graphs

- **Prerequisites**: bfs-dfs, hash-maps

### Tries
- **Description**: Prefix trees, autocomplete, word search
- **Front-end relevance**: Search autocomplete, command palettes, prefix matching in filters

- **Prerequisites**: trees, hash-maps
