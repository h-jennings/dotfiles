#!/usr/bin/env python3
"""
Rank Craft exercises and concepts by spaced-repetition review priority.

Higher priority = more worth revisiting. Uses a gentle, maintenance-appropriate
interval ladder keyed on the 1-5 `confidence` self-check (not a grade) — craft
fluency doesn't need aggressive re-drilling, just an occasional nudge.

Usage:
    python review_priority.py --type exercises
    python review_priority.py --type concepts
    python review_priority.py --type all
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path

# Reuse the indexer's frontmatter parsing so the two stay consistent.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from index_content import (  # noqa: E402
    get_repo_path,
    index_exercises,
    index_concepts,
)

# confidence (1-5) -> ideal days between reviews. 0/None handled via default.
# Gentler than dsa-a-day's Fibonacci ladder: this is upkeep, not cramming.
INTERVALS = {
    0: 2,
    1: 2,
    2: 5,
    3: 14,
    4: 30,
    5: 60,
}
DEFAULT_INTERVAL = INTERVALS[3]  # 14 days when confidence is unknown


def parse_date(date_str):
    """Parse a DD-MM-YYYY date string."""
    if not date_str:
        return None
    try:
        return datetime.strptime(date_str, "%d-%m-%Y")
    except (ValueError, TypeError):
        return None


def calculate_priority(item, today):
    """
    Calculate review priority. Higher = more urgent.

    - Never reviewed: days_since_created / ideal_interval + 10 (freshness bonus)
    - status=attempted gets +5 bonus (started but not landed, needs reinforcement)
    - Already reviewed: days_overdue / ideal_interval
    - No date info at all: max urgency (100)
    """
    conf = item.get("confidence")
    if conf is None:
        conf = 0
    ideal_interval = INTERVALS.get(conf, DEFAULT_INTERVAL)

    bonus = 5 if item.get("status") == "attempted" else 0

    last_reviewed = parse_date(item.get("last_reviewed"))

    if not last_reviewed:
        created = parse_date(item.get("created"))
        if created:
            days_since_created = (today - created).days
            return days_since_created / ideal_interval + 10 + bonus
        return 100  # no dates at all -> surface it

    days_since_review = (today - last_reviewed).days
    days_overdue = days_since_review - ideal_interval
    return days_overdue / ideal_interval + bonus


def days_ago_label(date_str, today):
    d = parse_date(date_str)
    if not d:
        return "never"
    n = (today - d).days
    return f"{n} day{'s' if n != 1 else ''} ago"


def main():
    parser = argparse.ArgumentParser(description="Rank Craft items by review priority")
    parser.add_argument(
        "--type",
        choices=["exercises", "concepts", "all"],
        default="all",
        help="Content type to rank (default: all)",
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

    if not items:
        print(f"No {args.type} found yet. Scaffold some first.")
        return 0

    today = datetime.now()
    for item in items:
        item["priority"] = calculate_priority(item, today)

    items.sort(key=lambda i: i["priority"], reverse=True)

    print(f"Review priority ({args.type}), most urgent first:\n")
    for item in items:
        ct = item.get("content_type", "?")
        title = item.get("title", item.get("slug", "unknown"))
        status = item.get("status", "")
        suffix = f" ({status})" if status else ""
        print(f"[{ct}] {title}{suffix}")

        tags = item.get("track") or ", ".join(item.get("topics") or []) or ", ".join(item.get("concepts") or [])
        if tags:
            print(f"   tags: {tags}")
        conf = item.get("confidence")
        print(f"   confidence: {f'{conf}/5' if conf is not None else 'not self-checked'}")
        print(f"   last reviewed: {days_ago_label(item.get('last_reviewed'), today)}")
        print(f"   priority: {item['priority']:.1f}")
        print(f"   file: {item.get('filepath')}")
        print()

    return 0


if __name__ == "__main__":
    sys.exit(main())
