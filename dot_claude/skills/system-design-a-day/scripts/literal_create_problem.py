#!/usr/bin/env python3
"""
Create a new front-end system design problem template with frontmatter,
a pre-scaffolded RADIO design doc, and an empty reference answer.

Usage:
    python create_problem.py "Dropdown Menu" --type ui-component --difficulty easy --topics "ui-components,accessibility"
    python create_problem.py "News Feed" --type application --difficulty medium --topics "feeds,pagination,real-time" --source greatfrontend --source-url "https://..."
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path


def get_repo_path():
    return Path.home() / "system-design-a-day"


def slugify(text):
    return text.lower().replace(" ", "-").replace("_", "-")


TYPE_TO_DIR = {
    "application": "applications",
    "ui-component": "ui-components",
}


def create_problem(title, problem_type="application", difficulty="medium", topics=None, source="original", source_url=""):
    """
    Create a new problem directory with scaffolded files.

    Returns:
        Path to created problem directory
    """
    if problem_type not in TYPE_TO_DIR:
        raise ValueError(f"Unknown type: {problem_type}. Must be one of {list(TYPE_TO_DIR)}")

    repo_path = get_repo_path()
    parent_dir = repo_path / TYPE_TO_DIR[problem_type]
    parent_dir.mkdir(parents=True, exist_ok=True)

    slug = slugify(title)
    problem_dir = parent_dir / slug

    if problem_dir.exists():
        print(f"Problem directory already exists: {problem_dir}")
        return problem_dir

    problem_dir.mkdir()

    date_str = datetime.now().strftime("%d-%m-%Y")
    topics_list = [t.strip() for t in topics.split(",")] if topics else [slug]
    topics_yaml = "[" + ", ".join(topics_list) + "]"

    # problem.md — the prompt
    problem_md = f"""---
title: {title}
type: {problem_type}
difficulty: {difficulty}
topics: {topics_yaml}
source: {source}
source_url: {source_url}
status: unsolved
understanding_score: null
last_practiced: null
last_quizzed: null
rubric_scores: null
created: {date_str}
last_updated: {date_str}
---

# {title}

## Prompt

[TODO: The conversational problem statement — what's being asked. For deep
sessions, this is all the candidate sees before starting Requirements
exploration.]

## Suggested constraints (revealed during Requirements)

[TODO: User base / scale, platform support, offline behavior, performance
targets, real-time needs, auth model. Used by the interviewer (Claude) to
answer the candidate's clarifying questions — NOT shown upfront.]

## Focus areas

[TODO: Which parts of the product deserve the Optimizations deep dive —
e.g. infinite scroll perf for News Feed, keyboard/a11y for Dropdown.]

---

## Q&A

[Questions and answers recorded during practice]

## Quiz History

[Quiz sessions recorded here]
"""

    # design.md — the user's working RADIO design doc, pre-scaffolded with section headers
    design_md = f"""# {title} — Design Notes

Working document for the RADIO walkthrough. Fill in each section as you
progress through the framework.

---

## R — Requirements exploration

**Time-box: <15% of session.**

### Functional requirements

- [TODO]

### Non-functional requirements

- [TODO — perf, scale, a11y, offline, i18n, multi-device]

### In scope / out of scope

- [TODO]

### Clarifying questions asked

- [TODO — list what you asked the interviewer and what they answered]

---

## A — Architecture / high-level design

**Time-box: ~20% of session.**

### Component diagram

```
[TODO: ASCII or mermaid diagram. Typical components: Server, Controller,
View (subviews), Model / Client Store. Arrows show data flow.]
```

### Component responsibilities

- **Server**: [TODO]
- **Client Store / Model**: [TODO]
- **Controller**: [TODO]
- **View**: [TODO]

### Where computation happens (client vs. server)

- [TODO]

---

## D — Data model

**Time-box: ~10% of session.**

| Entity | Fields | Source | Owner (component) |
|--------|--------|--------|--------------------|
| [TODO] |        |        |                    |

### Server-originated vs. client-only

- **Server-originated**: [TODO]
- **Client persistent**: [TODO]
- **Client ephemeral**: [TODO]

---

## I — Interface definition (API)

**Time-box: ~15% of session.**

### Server ↔ client APIs

- `GET /path` — [TODO: description]
  - Params: [TODO]
  - Response: [TODO]

### Client ↔ client interfaces

- [TODO: key function signatures / event shapes]

### Component props (for UI-component problems)

- [TODO: public API of the component]

---

## O — Optimizations and deep dive

**Time-box: ~40% of session. This is where most of the grade is earned.**

Pick the axes that matter most for *this* product. Don't try to cover all of them.

### Performance

- [TODO]

### Network

- [TODO: data transfer, caching, prefetch, compression, batching]

### User experience

- [TODO: loading states, optimistic updates, error handling]

### Accessibility

- [TODO]

### Internationalization

- [TODO]

### Multi-device / responsive

- [TODO]

### Security

- [TODO: XSS, CSRF, auth, rate limiting]

---

## Tradeoffs considered

- [TODO: for each major decision, what were the alternatives and why'd you choose this one]
"""

    # reference.md — empty, populated post-solve per user feedback memory
    reference_md = f"""# {title} — Reference Answer

*Populated after the practice session. Captures a common / canonical design so
future reviews can compare against a benchmark.*

## R — Requirements

[TODO: populated after solving]

## A — Architecture

[TODO]

## D — Data model

[TODO]

## I — Interface

[TODO]

## O — Optimizations deep dive

[TODO]

## Notable tradeoffs

[TODO]
"""

    (problem_dir / "problem.md").write_text(problem_md)
    (problem_dir / "design.md").write_text(design_md)
    (problem_dir / "reference.md").write_text(reference_md)

    return problem_dir


def main():
    parser = argparse.ArgumentParser(description="Create a new front-end system design problem template")
    parser.add_argument("title", help="Problem title (e.g., 'News Feed')")
    parser.add_argument(
        "--type",
        choices=list(TYPE_TO_DIR.keys()),
        default="application",
        help="Problem type (default: application)",
    )
    parser.add_argument(
        "--difficulty",
        choices=["easy", "medium", "hard"],
        default="medium",
        help="Problem difficulty (default: medium)",
    )
    parser.add_argument(
        "--topics",
        help="Comma-separated topics (e.g., 'feeds,pagination')",
        default=None,
    )
    parser.add_argument("--source", default="original", help="Problem source (default: original)")
    parser.add_argument("--source-url", default="", help="URL to original problem")

    args = parser.parse_args()

    try:
        problem_dir = create_problem(
            args.title,
            problem_type=args.type,
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
