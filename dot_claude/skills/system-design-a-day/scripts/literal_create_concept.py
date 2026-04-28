#!/usr/bin/env python3
"""
Create a new front-end system design concept tutorial template.

Usage:
    python create_concept.py "Client-Side Caching" --concepts "caching,service-workers"
    python create_concept.py "Unidirectional Data Flow" --concepts "architecture,state-management"
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path


def get_repo_path():
    return Path.home() / "system-design-a-day"


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

[TODO: What system design problem does this solve? Which RADIO phase does it
typically come up in? When should a candidate reach for it?]

## How It Works

[TODO: Mental model — diagrams, analogies, step-by-step walkthrough]

## Variants & Tradeoffs

[TODO: Alternatives and when to pick each. A strong answer names 2-3 options
and explains when each is appropriate.]

## When It Appears in RADIO

- **Requirements**: [TODO — what question makes this relevant?]
- **Architecture**: [TODO]
- **Data model**: [TODO]
- **Interface**: [TODO]
- **Optimizations**: [TODO — most concepts earn their grade here]

## Real-world Examples

[TODO: Which apps / companies use this? Cite specific patterns from real
products when possible.]

## Interview Pitfalls

[TODO: Common mistakes or shallow takes. What does a weak answer sound like?]

---

## Q&A

[Questions and answers recorded during learning]

## Quiz History

[Quiz sessions recorded here]
"""

    # examples.md — markdown instead of runnable TS
    examples_md = f"""# {title} — Worked Examples

Illustrative examples of the concept in action. Each example shows the
situation, the design choice, and why it was made.

## Example 1: [TODO]

**Context**: [TODO]

**Design**: [TODO]

**Why**: [TODO]

## Example 2: [TODO]

**Context**: [TODO]

**Design**: [TODO]

**Why**: [TODO]
"""

    # checklist.md — decision framework
    checklist_md = f"""# {title} — Decision Checklist

Use this when a problem feels like it might call for {title}. Answer the
questions in order; the answers narrow your design toward or away from this
approach.

## Should I reach for this?

- [ ] [TODO: key question 1]
- [ ] [TODO: key question 2]
- [ ] [TODO: key question 3]

## Red flags (don't use it when)

- [TODO]

## Green flags (strong fit when)

- [TODO]

## Follow-up questions to expect from interviewer

- [TODO]
"""

    (concept_dir / "concept.md").write_text(concept_md)
    (concept_dir / "examples.md").write_text(examples_md)
    (concept_dir / "checklist.md").write_text(checklist_md)

    return concept_dir


def main():
    parser = argparse.ArgumentParser(description="Create a new system design concept tutorial template")
    parser.add_argument("title", help="Concept title (e.g., 'Unidirectional Data Flow')")
    parser.add_argument(
        "--concepts",
        help="Comma-separated concept tags (e.g., 'architecture,state-management')",
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
