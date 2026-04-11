# Clarifying Questions Checklist

Reference for Step 2 (Clarify) of the 6-step framework. Treat these as a **filtering toolkit** — each question narrows the solution space by eliminating or enabling whole categories of approaches. The goal isn't to ask all 7 every time, but to develop the instinct for *which* questions matter for *this* problem.

## The 7 Questions

### 1. Can I use built-in functions and libraries?

- Why it matters: Don't waste time reimplementing a data structure that already exists. But know the cost — using a built-in doesn't make its complexity disappear.
- Filtering effect: If yes, standard library data structures are available. If no, you may need to implement your own (rare).

#### TS/JS Built-in Big O Reference

Know these cold — interviewers notice when you use a built-in without understanding its cost:

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| `Array.prototype.sort()` | O(n log n) | TimSort in V8 |
| `Array.prototype.includes()` / `indexOf()` | O(n) | Linear scan |
| `Array.prototype.push()` / `pop()` | O(1) amortized | |
| `Array.prototype.shift()` / `unshift()` | O(n) | Re-indexes entire array |
| `Array.prototype.splice()` | O(n) | Shifts elements |
| `Array.prototype.slice()` | O(n) | Creates copy |
| `Array.prototype.filter()` / `map()` / `forEach()` | O(n) | Full traversal + callback |
| `Array.prototype.reduce()` | O(n) | Full traversal + accumulator |
| `Map.get()` / `Map.set()` / `Map.has()` | O(1) average | Hash-based |
| `Set.has()` / `Set.add()` / `Set.delete()` | O(1) average | Hash-based |
| `Object.keys()` / `Object.values()` / `Object.entries()` | O(n) | Enumerates all properties |
| `String.prototype.includes()` / `indexOf()` | O(n*m) worst | n = string length, m = search length |
| `String.prototype.split()` | O(n) | Creates new array |
| `JSON.parse()` / `JSON.stringify()` | O(n) | Traverses entire structure |

**Common trap:** `.includes()` inside a loop = O(n^2). Replace with `Set.has()` for O(n) total.

### 2. What is the type of the input?

- Why it matters: `number` vs `bigint`, `string` vs `string[]`, integer vs float — these affect which operations are valid, how much space you need, and whether overflow is a concern.
- Filtering effect: Narrows data representation choices. Integer arrays open up counting sort and bit manipulation. Strings suggest character frequency or two-pointer approaches.

### 3. Will the input always be valid?

- Why it matters: Determines whether you need defensive coding (null checks, empty array handling, out-of-range values) or can focus purely on the core algorithm.
- Filtering effect: If yes, skip edge case handling and go straight to the happy path. If no, identify which edge cases matter before coding.

### 4. Does the input fit in memory?

- Why it matters: If the data doesn't fit on a single machine, you need distributed strategies (MapReduce, sharding, streaming). This comes up more in system design follow-ups, but asking shows you think at scale.
- Filtering effect: If yes (almost always for coding interviews), in-memory data structures are fair game. If no, discuss streaming or chunked approaches conceptually.

### 5. Is the input sorted?

- Why it matters: This is one of the highest-value questions. It eliminates or enables entire algorithm families.
- Filtering effect: If sorted → binary search is on the table, sorting algorithms are off, two-pointer techniques are likely useful. If unsorted → consider whether sorting first (O(n log n) cost) is worth it, or use hash-based approaches.

### 6. Can I modify the input in place?

- Why it matters: In-place modification avoids O(n) extra space but changes the original data. Some interviewers care, some don't.
- Filtering effect: If yes → in-place swaps, partitioning, two-pointer overwrites are all available. If no → you need to allocate new space for your result.

### 7. How do we define "optimal"?

- Why it matters: Don't assume you're always optimizing for time complexity. The interviewer might want space-optimal, the simplest correct implementation, or even the cheapest in terms of real-world cost.
- Filtering effect: Determines your optimization target. Time? Space? Readability? Implementation speed? Ask, don't assume. If the interviewer turns it back on you, state your preference and explain the tradeoff — that's the point.
