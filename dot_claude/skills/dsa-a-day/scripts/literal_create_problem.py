#!/usr/bin/env python3
"""
Create a new DSA problem template with frontmatter, starter code, and test file.

Usage:
    python create_problem.py "Two Sum" --difficulty easy --topics "arrays,hash-maps"
    python create_problem.py "Sliding Window Maximum" --difficulty hard --topics "sliding-window,deque" --source leetcode --source-url "https://..."
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path


def get_repo_path():
    return Path.home() / "dsa-a-day"


def slugify(text):
    return text.lower().replace(" ", "-").replace("_", "-")


def create_problem(title, difficulty="medium", topics=None, source="original", source_url=""):
    """
    Create a new problem directory with scaffolded files.

    Returns:
        Path to created problem directory
    """
    repo_path = get_repo_path()
    problems_dir = repo_path / "problems"
    problems_dir.mkdir(parents=True, exist_ok=True)

    slug = slugify(title)
    problem_dir = problems_dir / slug

    if problem_dir.exists():
        print(f"Problem directory already exists: {problem_dir}")
        return problem_dir

    problem_dir.mkdir()

    date_str = datetime.now().strftime("%d-%m-%Y")
    topics_list = [t.strip() for t in topics.split(",")] if topics else [slug]
    topics_yaml = "[" + ", ".join(topics_list) + "]"

    # problem.md
    problem_md = f"""---
title: {title}
difficulty: {difficulty}
topics: {topics_yaml}
source: {source}
source_url: {source_url}
status: unsolved
understanding_score: null
last_practiced: null
last_quizzed: null
time_complexity: null
space_complexity: null
created: {date_str}
last_updated: {date_str}
---

# {title}

## Problem

[TODO: Problem description]

## Examples

[TODO: Input/output examples]

## Constraints

[TODO: Constraints and edge cases]

## Expected Complexity

[TODO: Target time and space complexity]

---

## Q&A

[Questions and answers recorded during practice]

## Quiz History

[Quiz sessions recorded here]
"""

    # starter.ts
    starter_ts = f"""/**
 * {title}
 *
 * [TODO: Brief description]
 *
 * @param {{}} - [TODO: params]
 * @returns {{}} - [TODO: return type]
 */
export function {slug.replace("-", "")}() {{
  // TODO: implement
}}
"""

    # solution.test.ts
    test_ts = f"""import {{ describe, it, expect }} from "vitest";
// import {{ {slug.replace("-", "")} }} from "./solution";

describe("{title}", () => {{
  it.todo("should handle basic case");
  it.todo("should handle edge cases");
}});
"""

    (problem_dir / "problem.md").write_text(problem_md)
    (problem_dir / "starter.ts").write_text(starter_ts)
    (problem_dir / "solution.test.ts").write_text(test_ts)

    return problem_dir


def main():
    parser = argparse.ArgumentParser(description="Create a new DSA problem template")
    parser.add_argument("title", help="Problem title (e.g., 'Two Sum')")
    parser.add_argument(
        "--difficulty",
        choices=["easy", "medium", "hard"],
        default="medium",
        help="Problem difficulty (default: medium)",
    )
    parser.add_argument(
        "--topics",
        help="Comma-separated topics (e.g., 'arrays,hash-maps')",
        default=None,
    )
    parser.add_argument("--source", default="original", help="Problem source (default: original)")
    parser.add_argument("--source-url", default="", help="URL to original problem")

    args = parser.parse_args()

    try:
        problem_dir = create_problem(
            args.title,
            difficulty=args.difficulty,
            topics=args.topics,
            source=args.source,
            source_url=args.source_url,
        )
        print(f"Created problem: {problem_dir}")
        return 0
    except Exception as e:
        print(f"Error creating problem: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
