#!/usr/bin/env python3
"""
Index Craft exercises and concepts by extracting YAML frontmatter.

Usage:
    python index_content.py --type exercises
    python index_content.py --type concepts
    python index_content.py --type all --format human
    python index_content.py --type all --format json
"""

import argparse
import json
import re
import sys
from pathlib import Path


def get_repo_path():
    return Path.home() / "craft-a-day"


def extract_frontmatter(filepath):
    """Extract YAML frontmatter from a markdown file."""
    content = filepath.read_text()
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if not match:
        return None

    frontmatter_text = match.group(1)
    frontmatter = {}

    for line in frontmatter_text.split("\n"):
        line = line.strip()
        if ":" in line:
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip()

            # Handle null
            if value == "null" or value == "":
                value = None
            # Handle int fields
            elif key in ("confidence",):
                try:
                    value = int(value)
                except (ValueError, TypeError):
                    pass
            # Handle list fields
            elif key in ("topics", "concepts", "patterns", "related_exercises", "prerequisites"):
                if value and value.startswith("["):
                    inner = value.strip("[]").strip()
                    if inner:
                        value = [item.strip() for item in inner.split(",")]
                    else:
                        value = []

            frontmatter[key] = value

    return frontmatter


def index_exercises(repo_path):
    """Index all exercises."""
    exercises = []
    exercises_dir = repo_path / "exercises"
    if not exercises_dir.exists():
        return exercises

    for exercise_dir in sorted(exercises_dir.iterdir()):
        if not exercise_dir.is_dir():
            continue
        md_path = exercise_dir / "brief.md"
        if not md_path.exists():
            continue
        fm = extract_frontmatter(md_path)
        if fm:
            fm["slug"] = exercise_dir.name
            fm["filepath"] = str(md_path)
            fm["content_type"] = "exercise"
            fm["has_solution"] = (exercise_dir / "solution.ts").exists()
            exercises.append(fm)

    return exercises


def index_concepts(repo_path):
    """Index all concepts."""
    concepts = []
    concepts_dir = repo_path / "concepts"
    if not concepts_dir.exists():
        return concepts

    for concept_dir in sorted(concepts_dir.iterdir()):
        if not concept_dir.is_dir():
            continue
        md_path = concept_dir / "concept.md"
        if not md_path.exists():
            continue
        fm = extract_frontmatter(md_path)
        if fm:
            fm["slug"] = concept_dir.name
            fm["filepath"] = str(md_path)
            fm["content_type"] = "concept"
            concepts.append(fm)

    return concepts


def format_human_readable(items, content_type):
    """Format items as human-readable text."""
    if not items:
        return f"No {content_type} found."

    output = [f"Found {len(items)} {content_type}:\n"]

    exercises = [i for i in items if i.get("content_type") == "exercise"]
    if exercises:
        by_track = {}
        by_status = {}
        for e in exercises:
            t = e.get("track", "unknown")
            by_track[t] = by_track.get(t, 0) + 1
            s = e.get("status", "unknown")
            by_status[s] = by_status.get(s, 0) + 1
        output.append(f"  Exercises by track: {by_track}")
        output.append(f"  Exercises by status: {by_status}")
        output.append("")

    scored = [i for i in items if i.get("confidence") is not None]
    if scored:
        avg = sum(i["confidence"] for i in scored) / len(scored)
        output.append(f"  Avg confidence: {avg:.1f}/5 ({len(scored)} self-checked)")
        output.append("")

    for item in items:
        title = item.get("title", item.get("slug", "unknown"))
        ct = item.get("content_type", "?")
        output.append(f"  [{ct}] {title}")

        if item.get("track"):
            output.append(f"    Track: {item['track']}")
        if item.get("topics"):
            output.append(f"    Topics: {', '.join(item['topics']) if isinstance(item['topics'], list) else item['topics']}")
        if item.get("patterns"):
            output.append(f"    Patterns: {', '.join(item['patterns']) if isinstance(item['patterns'], list) else item['patterns']}")
        if item.get("concepts"):
            output.append(f"    Concepts: {', '.join(item['concepts']) if isinstance(item['concepts'], list) else item['concepts']}")
        if item.get("status"):
            output.append(f"    Status: {item['status']}")

        conf = item.get("confidence")
        output.append(f"    Confidence: {f'{conf}/5' if conf is not None else 'not self-checked'}")

        if item.get("last_practiced"):
            output.append(f"    Last practiced: {item['last_practiced']}")
        if item.get("last_quizzed"):
            output.append(f"    Last quizzed: {item['last_quizzed']}")
        if item.get("has_solution"):
            output.append(f"    Has solution: yes")

        output.append("")

    return "\n".join(output)


def main():
    parser = argparse.ArgumentParser(description="Index Craft exercises and concepts")
    parser.add_argument(
        "--type",
        choices=["exercises", "concepts", "all"],
        default="all",
        help="Content type to index (default: all)",
    )
    parser.add_argument(
        "--format",
        choices=["json", "human"],
        default="json",
        help="Output format (default: json)",
    )

    args = parser.parse_args()
    repo_path = get_repo_path()

    if not repo_path.exists():
        print("No Craft repo found at ~/craft-a-day/. Run setup.py first.", file=sys.stderr)
        return 1

    items = []
    if args.type in ("exercises", "all"):
        items.extend(index_exercises(repo_path))
    if args.type in ("concepts", "all"):
        items.extend(index_concepts(repo_path))

    if args.format == "json":
        print(json.dumps({"items": items, "count": len(items)}, indent=2))
    else:
        label = args.type if args.type != "all" else "items"
        print(format_human_readable(items, label))

    return 0


if __name__ == "__main__":
    sys.exit(main())
