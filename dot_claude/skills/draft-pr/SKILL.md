---
name: draft-pr
description: Create a draft GitHub PR with a clear, human, reviewer-friendly description that turns the author's own explanation of a change into prose worth reading. Use when the user wants to open or create a draft PR, write or draft a PR description, or turn a branch of commits into a pull request. The skill asks for the author's explanation, sanity-checks it against the actual diff, drafts the description, and only pushes and creates the draft PR after explicit approval.
---

# Draft PR

Turn the author's explanation of a change into a draft GitHub PR whose description actually gets read — not skimmed past as another filled-in form.

## Non-negotiable rules

1. **Never push or create the PR until the user explicitly approves.** Approval is an explicit "looks good", "ship it", "create it", "go ahead", or similar. Silence, a thumbs-up on the diff, or answering a clarifying question does **not** count. When in doubt, ask.
2. **Always create the PR as a draft** (`gh pr create --draft`). This skill never opens a ready-for-review PR.
3. **Never state anything the diff doesn't support.** The description describes the code that exists. If the author's explanation claims something not in the diff, resolve it before drafting — don't paper over it.
4. **The author owns the intent; you own the accuracy.** Both parties must be satisfied before creating.

## Workflow

### 1. Gather the change

Determine the branch and base, then read what actually changed:

```bash
git branch --show-current
gh repo view --json defaultBranchRef -q .defaultBranchRef.name   # base branch
git status
git log <base>..HEAD --oneline
git diff <base>...HEAD
```

Read the diff properly — this is what you'll sanity-check the explanation against. If `gh repo view` fails (no remote yet, or `gh` not authed), fall back to `git symbolic-ref refs/remotes/origin/HEAD` or ask the user for the base branch.

### 2. Ask for the author's explanation

Prompt the user, in their own words, for:
- **Why** they made this change (the problem/motivation), and
- **What** it does.

This is the source of truth for *intent*. Don't skip it and don't guess it from the diff — the whole point is to capture the human reasoning the code can't show.

### 3. Light sanity check

Cross-check the explanation against the diff at a high level. Surface — as questions, not corrections:
- **Contradictions** — claims in the explanation the code doesn't back up.
- **Major omissions** — significant changes in the diff the explanation didn't mention.

This is a sanity check, not a line-by-line audit. Trust the author on details; only flag things that are clearly off or clearly missing. Resolve anything flagged before moving on.

### 4. Draft the description

Apply the template below and the writing principles in `references/writing-descriptions.md` (read it before drafting). Print the **full title and body** to the terminal so the user sees exactly what will be created.

**Do not hard-wrap paragraphs.** GitHub renders a single newline inside a paragraph as a literal `<br>`, so manually wrapping prose at ~72/80 columns produces broken-looking mid-sentence line breaks. Write each paragraph and each bullet as one continuous line; use blank lines only to separate paragraphs, list items, and headings. Let the reader's browser do the wrapping.

### 5. Approval gate — stop and wait

Iterate on the draft until **both** are true: the user has explicitly approved, and you're satisfied the description is accurate to the diff. **Do not run any push or create command before this.** State plainly that you're waiting for approval.

### 6. Push and create

Once approved:

```bash
git push -u origin <branch>
gh pr create --draft --base <base> --title "<title>" --body "<body>"
```

**Edge cases — stop and ask first:**
- On the default branch (no feature branch): ask whether to create a branch first.
- Uncommitted changes present: ask whether to commit them, and how, before pushing.

### 7. Report

Print the resulting PR URL.

## PR template

A **starting shape, not a form to fill in.** The `<!-- ... -->` comments are guiding placeholders — they nudge the author to add the right context when it's relevant, and are then filled in or deleted. They never render as empty headings in the final PR.

Headings are optional: if a tight two-paragraph narrative reads better than labeled sections, use that instead. Delete any section that isn't earning its place — don't leave it blank.

```markdown
## Why

<!-- The problem or motivation, for a reviewer with ZERO context. Write like a person, not a form. This is the hook — keep it short and real. -->

## What changed

<!-- The change itself, in short well-written paragraphs. Use bullets only if they're genuinely clearer. -->

<!--
Screenshots — ONLY if this change is user-visible (UI/output).
Add a before/after image so the diff is legible at a glance.
Delete this whole block for non-visible (backend/refactor) changes.
-->

<!--
Testing — how a reviewer can verify this, or the cases you already checked.
e.g. "Ran X with input Y, got Z." Delete if it adds nothing.
-->

<!--
Notes — tradeoffs, follow-ups, or anything worth flagging. Delete if empty.
-->
```

The final rendered PR shows only the sections the author actually filled; the comment prompts guide during authoring and disappear when removed.

## Writing the description

The single goal: **beat template blindness.** A complete, every-section-filled PR that reads like a form gets skimmed and ignored. A short, human description that leads with a real "why" gets read.

For the principles (no assumed context, short paragraphs, screenshots only when visible, concrete testing cases, cut what isn't earning its place) with before/after examples and a full worked example, read `references/writing-descriptions.md`.
