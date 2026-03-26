---
description: Generate a comprehensive quarterly work report from git commits, PRs, and Linear issues
args: <quarter> [output-dir]
examples:
  - quarterly-report Q1 2026
  - quarterly-report Q4 2025 ~/Documents/reports
  - quarterly-report "Sept 2025 - Jan 2026"
---

Generate a comprehensive quarterly work report for Hunter Jennings based on git commit history, PR activity, and optionally Linear issues.

## Instructions

1. **Parse the time period**: Extract the quarter or date range from the argument
   - If format is "Q1 2026", calculate the date range (Jan 1 - Mar 31, 2026)
   - If format is "Q4 2025", calculate (Oct 1 - Dec 31, 2025)
   - If custom range like "Sept 2025 - Jan 2026", parse accordingly
   - Default to current quarter if no arg provided

2. **Gather commit data**:
   ```bash
   git log --author="Hunter Jennings" --since="YYYY-MM-DD" --until="YYYY-MM-DD" --pretty=format:"%ad|%s" --date=short --no-merges
   ```
   - Count total commits
   - Group by feature area based on commit prefixes (feat, refactor, fix, chore)
   - Identify major themes and features

3. **Analyze feature work**:
   - Group related commits into high-level features (4-6 major areas)
   - Look for patterns in commit messages to identify:
     - New features (feat:)
     - Major refactors
     - Infrastructure work
     - Bug fixes that represent significant work
   - Organize chronologically to tell a story
   - Focus on business impact and technical complexity

4. **Generate reports**:
   - Create markdown report with:
     - Title: "Hunter Jennings - Q[X] [YEAR] Feature Work Report"
     - Period and total commits
     - 4-6 major feature sections with timeline and commit counts
     - Each feature should have subsections organized chronologically
     - Supporting work section for smaller items
     - Summary with key takeaways

   - Create Roam-compatible report with:
     - Bullet-based hierarchy (2 spaces per indent level)
     - Same content structure as markdown
     - Easy to copy/paste into Roam Research

5. **Determine output location**:
   - If output directory provided as second arg, use that
   - Otherwise, save to current working directory
   - Filenames: `hunter-jennings-q[X]-[year]-work.md` and `hunter-jennings-q[X]-[year]-work-roam.txt`

6. **Provide summary**:
   - Show user where files were saved
   - Give brief overview of findings (total commits, major features)
   - Suggest next steps (e.g., add to portfolio, share with manager)

## Tips for Analysis

- **Feature identification**: Look for commit message patterns
  - Multiple commits with same prefix (e.g., "feat(browser-extension)") = major feature
  - WIP commits followed by final implementation = greenfield project
  - Archive/remove/CRUD patterns = settings/management system

- **Timeline construction**: Use commit dates to build narrative
  - Group by month or phase of work
  - Show progression (foundation → integration → polish → ship)

- **Impact focus**: Emphasize
  - Greenfield projects (built from scratch)
  - Production releases
  - Complex technical challenges
  - User-facing improvements

- **Keep it concise**:
  - 4-6 major features max
  - Supporting work section for smaller items
  - Focus on "what" and "why", not every implementation detail

## Example Output Structure

```
# Hunter Jennings - Q4 2025 Feature Work Report
**Period**: October - December 2025
**Total Commits**: 222

## 1. Major Feature Name
**Timeline** | ~XX commits
- High-level description
- Key accomplishments
- Technical highlights
- Ship date if applicable

## 2. Another Major Feature
...

## Summary
- 4-5 bullet points with key takeaways
- Mix of project types
- Focus areas
```
