#!/usr/bin/env python3
"""
Set up the central DSA practice repository.

Usage:
    python setup.py
    python setup.py --create-github-repo

Creates ~/dsa-a-day/ if it doesn't exist, initializes git,
and optionally creates a private GitHub repository.
"""

import argparse
import subprocess
import sys
from pathlib import Path


def get_repo_path():
    """Get the path for the DSA practice repo."""
    return Path.home() / "dsa-a-day"


README_CONTENT = """# DSA a Day

Personal DSA practice repository. Problems and concept tutorials are scaffolded
by the `dsa-a-day` Claude Code skill and tracked with spaced repetition.

## Structure

- `problems/` — Each subdirectory is a self-contained problem (markdown + starter + tests)
- `concepts/` — Each subdirectory is a concept tutorial (markdown + examples + exercise)
- `learner_profile.md` — Learning context and preferences
"""

TSCONFIG_CONTENT = """{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "./dist",
    "rootDir": ".",
    "declaration": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["problems/**/*.ts", "concepts/**/*.ts"],
  "exclude": ["node_modules", "dist"]
}
"""

GITIGNORE_CONTENT = """.DS_Store
node_modules/
dist/
*.swp
*.swo
"""


def setup_repo(create_github=False):
    """
    Set up the DSA practice repository.

    Returns:
        tuple: (success: bool, message: str)
    """
    repo_path = get_repo_path()

    if repo_path.exists():
        # Ensure subdirs exist even if repo was partially set up
        (repo_path / "problems").mkdir(exist_ok=True)
        (repo_path / "concepts").mkdir(exist_ok=True)
        return True, f"DSA repo already exists at {repo_path.resolve()}"

    try:
        repo_path.mkdir(parents=True)
        (repo_path / "problems").mkdir()
        (repo_path / "concepts").mkdir()

        # Initialize git
        subprocess.run(["git", "init"], cwd=repo_path, check=True, capture_output=True)

        # Create files
        (repo_path / "README.md").write_text(README_CONTENT)
        (repo_path / ".gitignore").write_text(GITIGNORE_CONTENT)
        (repo_path / "tsconfig.json").write_text(TSCONFIG_CONTENT)

        # Initial commit
        subprocess.run(["git", "add", "-A"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(
            ["git", "commit", "-m", "Initial commit: dsa-a-day practice repo"],
            cwd=repo_path,
            check=True,
            capture_output=True,
        )

        message = f"Created DSA repo at {repo_path.resolve()}"

        if create_github:
            result = subprocess.run(
                ["gh", "repo", "create", "dsa-a-day", "--private", "--source=.", "--push"],
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
        return False, f"Error setting up DSA repo: {e}"


def main():
    parser = argparse.ArgumentParser(description="Set up the DSA practice repository")
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
