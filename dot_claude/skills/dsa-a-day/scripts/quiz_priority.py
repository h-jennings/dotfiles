#!/usr/bin/env python3
"""
Prioritize problems and concepts for quizzing based on spaced repetition.

Usage:
    python quiz_priority.py
    python quiz_priority.py --type problems
    python quiz_priority.py --type concepts
"""

import argparse
import re
from datetime import datetime
from pathlib import Path


def get_repo_path():
    return Path.home() / "dsa-a-day"


# Fibonacci-ish spaced repetition intervals (days between reviews)
INTERVALS = {
    0: 1,
    1: 2,
    2: 3,
    3: 5,
    4: 8,
    5: 13,
    6: 21,
    7: 34,
    8: 55,
    9: 89,
    10: 144,
}


def parse_frontmatter(filepath):
    """Extract YAML frontmatter from markdown file."""
    content = filepath.read_text()
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if not match:
        return None

    frontmatter_text = match.group(1)
    metadata = {"filepath": str(filepath)}

    for line in frontmatter_text.split("\n"):
        line = line.strip()
        if ":" in line:
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip()

            if value == "null" or value == "":
                value = None
            elif key == "understanding_score" and value:
                try:
                    value = int(value)
                except ValueError:
                    pass
            elif key in ("topics", "concepts") and value and value.startswith("["):
                inner = value.strip("[]").strip()
                value = [item.strip() for item in inner.split(",")] if inner else []

            metadata[key] = value

    return metadata


def parse_date(date_value):
    """Parse DD-MM-YYYY date string."""
    if isinstance(date_value, str):
        return datetime.strptime(date_value, "%d-%m-%Y").date()
    return date_value


def calculate_priority(item, today):
    """
    Calculate quiz priority. Higher = more urgent.

    - Never quizzed: days_since_created / ideal_interval + 10 (bonus)
    - status=attempted gets +5 bonus (not yet solved, needs reinforcement)
    - Already quizzed: days_overdue / ideal_interval
    - No date info: max urgency (100)
    """
    score = item.get("understanding_score") or 0
    ideal_interval = INTERVALS.get(score, INTERVALS[5])

    last_quizzed = item.get("last_quizzed")

    bonus = 0
    if item.get("status") == "attempted":
        bonus = 5

    if not last_quizzed:
        created = item.get("created")
        if created:
            created = parse_date(created)
            days_since_created = (today - created).days
            return days_since_created / ideal_interval + 10 + bonus
        return 100

    last_quizzed = parse_date(last_quizzed)
    days_since_quiz = (today - last_quizzed).days
    days_overdue = days_since_quiz - ideal_interval

    return days_overdue / ideal_interval + bonus


def collect_items(repo_path, content_type):
    """Collect items from problems and/or concepts directories."""
    items = []

    if content_type in ("problems", "all"):
        problems_dir = repo_path / "problems"
        if problems_dir.exists():
            for d in sorted(problems_dir.iterdir()):
                md = d / "problem.md"
                if md.exists():
                    meta = parse_frontmatter(md)
                    if meta:
                        meta["content_type"] = "problem"
                        meta["slug"] = d.name
                        items.append(meta)

    if content_type in ("concepts", "all"):
        concepts_dir = repo_path / "concepts"
        if concepts_dir.exists():
            for d in sorted(concepts_dir.iterdir()):
                md = d / "concept.md"
                if md.exists():
                    meta = parse_frontmatter(md)
                    if meta:
                        meta["content_type"] = "concept"
                        meta["slug"] = d.name
                        items.append(meta)

    return items


def main():
    parser = argparse.ArgumentParser(
        description="Prioritize DSA content for quizzing via spaced repetition"
    )
    parser.add_argument(
        "--type",
        choices=["problems", "concepts", "all"],
        default="all",
        help="Content type to prioritize (default: all)",
    )

    args = parser.parse_args()
    repo_path = get_repo_path()

    if not repo_path.exists():
        print("No DSA repo found at ~/dsa-a-day/. Run setup.py first.")
        return

    today = datetime.now().date()
    items = collect_items(repo_path, args.type)

    if not items:
        print("No content found to quiz.")
        return

    for item in items:
        item["priority"] = calculate_priority(item, today)

    items.sort(key=lambda t: t["priority"], reverse=True)

    print("=" * 60)
    print("QUIZ PRIORITY (most urgent first)")
    print("=" * 60)
    print()

    for i, item in enumerate(items, 1):
        score = item.get("understanding_score") or 0
        last_q = item.get("last_quizzed")
        ct = item.get("content_type", "?")
        title = item.get("title", item.get("slug", "unknown"))

        # Topics or concepts label
        tags = item.get("topics") or item.get("concepts") or []
        if isinstance(tags, list):
            tags_str = ", ".join(tags[:3])
        else:
            tags_str = str(tags)

        if last_q:
            last_q_date = parse_date(last_q)
            days_ago = (today - last_q_date).days
            last_quizzed_str = f"{days_ago} days ago"
        else:
            last_quizzed_str = "never"

        status = item.get("status", "")
        status_str = f" ({status})" if status else ""

        print(f"{i}. [{ct}] {title}{status_str}")
        print(f"   tags: {tags_str}")
        print(f"   understanding_score: {score}/10")
        print(f"   last_quizzed: {last_quizzed_str}")
        print(f"   priority: {item['priority']:.1f}")
        print(f"   file: {item['filepath']}")
        print()


if __name__ == "__main__":
    main()
