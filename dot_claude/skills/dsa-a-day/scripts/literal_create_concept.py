#!/usr/bin/env python3
"""
Create a new DSA concept tutorial template.

Usage:
    python create_concept.py "Hash Maps" --concepts "hash-maps,dictionaries"
    python create_concept.py "Sliding Window" --concepts "sliding-window,two-pointers"
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path


def get_repo_path():
    return Path.home() / "dsa-a-day"


def slugify(text):
    return text.lower().replace(" ", "-").replace("_", "-")


def create_concept(title, concepts=None):
    """
    Create a new concept directory with scaffolded files.

    Returns:
        Path to created concept directory
    """
    repo_path = get_repo_path()
    concepts_dir = repo_path / "concepts"
    concepts_dir.mkdir(parents=True, exist_ok=True)

    slug = slugify(title)
    concept_dir = concepts_dir / slug

    if concept_dir.exists():
        print(f"Concept directory already exists: {concept_dir}")
        return concept_dir

    concept_dir.mkdir()

    date_str = datetime.now().strftime("%d-%m-%Y")
    concepts_list = [c.strip() for c in concepts.split(",")] if concepts else [slug]
    concepts_yaml = "[" + ", ".join(concepts_list) + "]"

    # concept.md
    concept_md = f"""---
title: {title}
concepts: {concepts_yaml}
related_problems: []
understanding_score: null
last_quizzed: null
prerequisites: []
created: {date_str}
last_updated: {date_str}
---

# {title}

## Why This Matters

[TODO: Start with the problem this data structure / algorithm solves. Why should you care?]

## How It Works

[TODO: Build mental model — diagrams, analogies, step-by-step walkthrough]

## Implementation

[TODO: Core implementation details. Reference examples.ts for runnable code]

## When to Use

[TODO: Decision framework — when to reach for this vs alternatives. Tradeoffs]

## Complexity

| Operation | Time | Space |
|-----------|------|-------|
| [TODO]    |      |       |

## Front-End Relevance

[TODO: Where this shows up in real front-end work — React state, DOM manipulation, event handling, etc.]

---

## Q&A

[Questions and answers recorded during learning]

## Quiz History

[Quiz sessions recorded here]
"""

    # examples.ts
    examples_ts = f"""/**
 * {title} — Runnable Examples
 *
 * Run with: pnpm tsx concepts/{slug}/examples.ts
 *
 * Each example demonstrates a key aspect of the concept.
 */

// Example 1: Basic usage
// [TODO: Fill in with demonstrative code]

console.log("=== {title} Examples ===");
console.log("TODO: Add examples");
"""

    # exercise.ts
    exercise_ts = f"""/**
 * {title} — Practice Exercise
 *
 * Complete the exercises below to cement your understanding.
 * Run with: pnpm tsx concepts/{slug}/exercise.ts
 */

// Exercise 1: [TODO: Description]
// Implement the function below.

export function exercise1() {{
  // TODO: implement
}}

// Verify
// console.log(exercise1());
"""

    (concept_dir / "concept.md").write_text(concept_md)
    (concept_dir / "examples.ts").write_text(examples_ts)
    (concept_dir / "exercise.ts").write_text(exercise_ts)

    return concept_dir


def main():
    parser = argparse.ArgumentParser(description="Create a new DSA concept tutorial template")
    parser.add_argument("title", help="Concept title (e.g., 'Hash Maps')")
    parser.add_argument(
        "--concepts",
        help="Comma-separated concept tags (e.g., 'hash-maps,dictionaries')",
        default=None,
    )

    args = parser.parse_args()

    try:
        concept_dir = create_concept(args.title, concepts=args.concepts)
        print(f"Created concept: {concept_dir}")
        return 0
    except Exception as e:
        print(f"Error creating concept: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
