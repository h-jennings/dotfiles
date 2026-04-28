#!/usr/bin/env python3
"""
Index front-end system design problems and concepts by extracting YAML
frontmatter.

Usage:
    python index_content.py --type problems
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
    return Path.home() / "system-design-a-day"


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
            elif key in ("understanding_score",):
                try:
                    value = int(value)
                except (ValueError, TypeError):
                    pass
            # Handle list fields
            elif key in ("topics", "concepts", "related_problems", "prerequisites"):
                if value and value.startswith("["):
                    inner = value.strip("[]").strip()
                    if inner:
                        value = [item.strip() for item in inner.split(",")]
                    else:
                        value = []

            frontmatter[key] = value

    return frontmatter


# Problems live in two parallel directories; both use problem.md + design.md + reference.md.
PROBLEM_DIRS = ("applications", "ui-components")


def index_problems(repo_path):
    """Index all problems across applications/ and ui-components/."""
    problems = []

    for subdir in PROBLEM_DIRS:
        parent_dir = repo_path / subdir
        if not parent_dir.exists():
            continue

        for problem_dir in sorted(parent_dir.iterdir()):
            md_path = problem_dir / "problem.md"
            if not md_path.exists():
                continue
            fm = extract_frontmatter(md_path)
            if fm:
                fm["slug"] = problem_dir.name
                fm["filepath"] = str(md_path)
                fm["content_type"] = "problem"
                fm["category"] = subdir
                # Check if design.md has meaningful content (not just scaffolding)
                design_path = problem_dir / "design.md"
                if design_path.exists():
                    design_content = design_path.read_text()
                    # Crude heuristic: if > 2000 chars and fewer than half are [TODO] markers,
                    # consider it worked. Otherwise just note presence.
                    fm["has_design"] = len(design_content) > 0
                reference_path = problem_dir / "reference.md"
                fm["has_reference"] = reference_path.exists() and "[TODO" not in reference_path.read_text()[:500] if reference_path.exists() else False
                problems.append(fm)

    return problems


def index_concepts(repo_path):
    """Index all concepts."""
    concepts = []
    concepts_dir = repo_path / "concepts"
    if not concepts_dir.exists():
        return concepts

    for concept_dir in sorted(concepts_dir.iterdir()):
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

    problems = [i for i in items if i.get("content_type") == "problem"]
    if problems:
        by_type = {}
        by_diff = {}
        by_status = {}
        by_topic = {}
        for p in problems:
            t = p.get("type", "unknown")
            by_type[t] = by_type.get(t, 0) + 1
            d = p.get("difficulty", "unknown")
            by_diff[d] = by_diff.get(d, 0) + 1
            s = p.get("status", "unknown")
            by_status[s] = by_status.get(s, 0) + 1
            for topic in p.get("topics", []) or []:
                by_topic[topic] = by_topic.get(topic, 0) + 1

        output.append(f"  Problems by type: {by_type}")
        output.append(f"  Problems by difficulty: {by_diff}")
        output.append(f"  Problems by status: {by_status}")
        output.append(f"  Topic coverage: {by_topic}")
        output.append("")

    scored = [i for i in items if i.get("understanding_score") is not None]
    if scored:
        avg = sum(i["understanding_score"] for i in scored) / len(scored)
        output.append(f"  Avg understanding score: {avg:.1f}/10 ({len(scored)} scored)")
        output.append("")

    for item in items:
        title = item.get("title", item.get("slug", "unknown"))
        ct = item.get("content_type", "?")
        category = item.get("category", "")
        cat_label = f"/{category}" if category else ""
        output.append(f"  [{ct}{cat_label}] {title}")

        if item.get("type"):
            output.append(f"    Type: {item['type']}")
        if item.get("difficulty"):
            output.append(f"    Difficulty: {item['difficulty']}")
        if item.get("topics"):
            output.append(f"    Topics: {', '.join(item['topics']) if isinstance(item['topics'], list) else item['topics']}")
        if item.get("concepts"):
            output.append(f"    Concepts: {', '.join(item['concepts']) if isinstance(item['concepts'], list) else item['concepts']}")
        if item.get("status"):
            output.append(f"    Status: {item['status']}")

        score = item.get("understanding_score")
        output.append(f"    Understanding: {f'{score}/10' if score is not None else 'not quizzed'}")

        if item.get("last_practiced"):
            output.append(f"    Last practiced: {item['last_practiced']}")
        if item.get("last_quizzed"):
            output.append(f"    Last quizzed: {item['last_quizzed']}")
        if item.get("has_reference"):
            output.append(f"    Has reference answer: yes")

        output.append("")

    return "\n".join(output)


def main():
    parser = argparse.ArgumentParser(description="Index system design problems and concepts")
    parser.add_argument(
        "--type",
        choices=["problems", "concepts", "all"],
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
        print("No system-design repo found at ~/system-design-a-day/. Run setup.py first.", file=sys.stderr)
        return 1

    items = []
    if args.type in ("problems", "all"):
        items.extend(index_problems(repo_path))
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
