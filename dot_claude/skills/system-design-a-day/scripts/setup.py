#!/usr/bin/env python3
"""
Set up the central front-end system design practice repository.

Usage:
    python setup.py
    python setup.py --create-github-repo

Creates ~/system-design-a-day/ if it doesn't exist, initializes git,
and optionally creates a private GitHub repository.
"""

import argparse
import subprocess
import sys
from pathlib import Path


def get_repo_path():
    """Get the path for the system design practice repo."""
    return Path.home() / "system-design-a-day"


README_CONTENT = """# System Design a Day

Personal front-end system design practice repository. Problems and concept
tutorials are scaffolded by the `system-design-a-day` Claude Code skill and
tracked with spaced repetition.

Modeled on the RADIO framework from the GreatFrontend Front-End System Design
Playbook.

## Structure

- `applications/` — Full-application design problems (News Feed, Chat, Netflix, etc.)
- `ui-components/` — Component-scale design problems (Dropdown, Autocomplete, Data Table, etc.)
- `concepts/` — Building-block tutorials (state management, caching, rendering strategies, etc.)
- `learner_profile.md` — Learning context and preferences

## RADIO framework

Every problem is worked through the RADIO framework:

1. **R**equirements exploration (<15% of session)
2. **A**rchitecture / high-level design (~20%)
3. **D**ata model (~10%)
4. **I**nterface definition / API (~15%)
5. **O**ptimizations and deep dive (~40%)
"""

GITIGNORE_CONTENT = """.DS_Store
*.swp
*.swo
"""


def setup_repo(create_github=False):
    """
    Set up the system design practice repository.

    Returns:
        tuple: (success: bool, message: str)
    """
    repo_path = get_repo_path()

    if repo_path.exists():
        # Ensure subdirs exist even if repo was partially set up
        (repo_path / "applications").mkdir(exist_ok=True)
        (repo_path / "ui-components").mkdir(exist_ok=True)
        (repo_path / "concepts").mkdir(exist_ok=True)
        return True, f"System design repo already exists at {repo_path.resolve()}"

    try:
        repo_path.mkdir(parents=True)
        (repo_path / "applications").mkdir()
        (repo_path / "ui-components").mkdir()
        (repo_path / "concepts").mkdir()

        # Initialize git
        subprocess.run(["git", "init"], cwd=repo_path, check=True, capture_output=True)

        # Create files
        (repo_path / "README.md").write_text(README_CONTENT)
        (repo_path / ".gitignore").write_text(GITIGNORE_CONTENT)

        # Initial commit
        subprocess.run(["git", "add", "-A"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(
            ["git", "commit", "-m", "Initial commit: system-design-a-day practice repo"],
            cwd=repo_path,
            check=True,
            capture_output=True,
        )

        message = f"Created system design repo at {repo_path.resolve()}"

        if create_github:
            result = subprocess.run(
                ["gh", "repo", "create", "system-design-a-day", "--private", "--source=.", "--push"],
                cwd=repo_path,
                capture_output=True,
                text=True,
            )
            if result.returncode == 0:
                message += "\nCreated private GitHub repo and pushed"
            else:
                message += f"\nNote: Could not create GitHub repo: {result.stderr}"

        return True, message

    except Exception as e:
        return False, f"Error setting up system design repo: {e}"


def main():
    parser = argparse.ArgumentParser(description="Set up the system design practice repository")
    parser.add_argument(
        "--create-github-repo",
        action="store_true",
        help="Also create a private GitHub repository",
    )

    args = parser.parse_args()
    success, message = setup_repo(create_github=args.create_github_repo)
    print(message)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
