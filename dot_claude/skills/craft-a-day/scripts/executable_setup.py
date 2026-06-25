#!/usr/bin/env python3
"""
Set up the central Craft a Day practice repository.

Usage:
    python setup.py
    python setup.py --create-github-repo

Creates ~/craft-a-day/ if it doesn't exist, initializes git, scaffolds the
TypeScript toolchain (pnpm + vitest + tsx), and optionally creates a private
GitHub repository.
"""

import argparse
import subprocess
import sys
from pathlib import Path


def get_repo_path():
    """Get the path for the Craft practice repo."""
    return Path.home() / "craft-a-day"


README_CONTENT = """# Craft a Day

Personal programming-craft practice repository. Exercises and concept tutorials
are scaffolded by the `craft-a-day` Claude Code skill and tracked with light
spaced repetition. The point is staying fluent in the everyday craft of writing
good code — not interview prep (that's `dsa-a-day` / `system-design-a-day`).

## Structure

- `exercises/` — Each subdirectory is one self-contained exercise. A `track`
  field in the frontmatter (build | refactor | fluency | testing | debugging |
  async) marks its kind; it's a flat mixed bag on purpose, so sessions stay fresh.
- `concepts/` — Each subdirectory is a concept tutorial (markdown + runnable examples + exercise).
- `learnings.md` — Running one-line log of what each session taught. "Record What You Learn."
- `learner_profile.md` — Calibration: comfort, goals, preferences.

## Toolchain

```bash
pnpm install
pnpm vitest run            # run all tests
pnpm vitest run exercises/<slug>   # run one exercise's tests
pnpm tsx exercises/<slug>/file.ts  # run a TS file directly
pnpm typecheck            # tsc --noEmit (catches type-puzzle asserts)
```
"""

TSCONFIG_CONTENT = """{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "./dist",
    "rootDir": ".",
    "declaration": false,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["exercises/**/*.ts", "concepts/**/*.ts"],
  "exclude": ["node_modules", "dist"]
}
"""

PACKAGE_JSON_CONTENT = """{
  "name": "craft-a-day",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "vitest run",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "tsx": "^4.19.0",
    "typescript": "^5.6.0",
    "vitest": "^2.1.0"
  }
}
"""

# Node environment + globals. The async track uses vitest's fake timers
# (vi.useFakeTimers) for timing-based reps — no extra setup needed.
VITEST_CONFIG_CONTENT = """import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
  },
});
"""

LEARNINGS_CONTENT = """# Learnings

A running log of what each craft session taught — one line per insight.
"Record What You Learn." Newest at the bottom.

<!-- Format: - YYYY-MM-DD [track] one-line takeaway (exercise-slug) -->
"""

GITIGNORE_CONTENT = """.DS_Store
node_modules/
dist/
*.swp
*.swo
"""


def setup_repo(create_github=False):
    """
    Set up the Craft practice repository.

    Returns:
        tuple: (success: bool, message: str)
    """
    repo_path = get_repo_path()

    if repo_path.exists():
        # Ensure subdirs / scaffolding exist even if repo was partially set up
        (repo_path / "exercises").mkdir(exist_ok=True)
        (repo_path / "concepts").mkdir(exist_ok=True)
        for name, content in (
            ("README.md", README_CONTENT),
            (".gitignore", GITIGNORE_CONTENT),
            ("tsconfig.json", TSCONFIG_CONTENT),
            ("package.json", PACKAGE_JSON_CONTENT),
            ("vitest.config.ts", VITEST_CONFIG_CONTENT),
            ("learnings.md", LEARNINGS_CONTENT),
        ):
            f = repo_path / name
            if not f.exists():
                f.write_text(content)
        return True, f"Craft repo already exists at {repo_path.resolve()}"

    try:
        repo_path.mkdir(parents=True)
        (repo_path / "exercises").mkdir()
        (repo_path / "concepts").mkdir()

        # Initialize git
        subprocess.run(["git", "init"], cwd=repo_path, check=True, capture_output=True)

        # Create files
        (repo_path / "README.md").write_text(README_CONTENT)
        (repo_path / ".gitignore").write_text(GITIGNORE_CONTENT)
        (repo_path / "tsconfig.json").write_text(TSCONFIG_CONTENT)
        (repo_path / "package.json").write_text(PACKAGE_JSON_CONTENT)
        (repo_path / "vitest.config.ts").write_text(VITEST_CONFIG_CONTENT)
        (repo_path / "learnings.md").write_text(LEARNINGS_CONTENT)

        # Initial commit
        subprocess.run(["git", "add", "-A"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(
            ["git", "commit", "-m", "Initial commit: craft-a-day practice repo"],
            cwd=repo_path,
            check=True,
            capture_output=True,
        )

        message = f"Created Craft repo at {repo_path.resolve()}"

        if create_github:
            result = subprocess.run(
                ["gh", "repo", "create", "craft-a-day", "--private", "--source=.", "--push"],
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
        return False, f"Error setting up Craft repo: {e}"


def main():
    parser = argparse.ArgumentParser(description="Set up the Craft practice repository")
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
