# Writing PR descriptions that get read

The enemy is **template blindness**: a PR that fills every heading reads like a form, and reviewers' eyes slide right off it. A description that leads with a real "why" and sounds like a person wrote it gets read. Everything below serves that one goal.

## Contents

- [Principle 1: Beat template blindness](#principle-1-beat-template-blindness)
- [Principle 2: Assume the reader has zero context](#principle-2-assume-the-reader-has-zero-context)
- [Principle 3: Short, well-written paragraphs](#principle-3-short-well-written-paragraphs)
- [Principle 3.5: Never hard-wrap paragraphs](#principle-35-never-hard-wrap-paragraphs)
- [Principle 4: Screenshots — only when the change is visible](#principle-4-screenshots--only-when-the-change-is-visible)
- [Principle 5: Concrete testing cases](#principle-5-concrete-testing-cases)
- [Principle 6: Don't fill a section for the sake of it](#principle-6-dont-fill-a-section-for-the-sake-of-it)
- [Full worked example](#full-worked-example)

## Principle 1: Beat template blindness

Structure serves the reader; it is never scaffolding to fill. If a heading has nothing real under it, the heading is the problem — delete it.

**Before** (every box checked, nothing communicated):
> ## Summary
> This PR makes some changes.
> ## Changes
> - Updated code
> - Fixed issues
> ## Testing
> Tested locally.
> ## Screenshots
> N/A

**After** (leads with the point, drops the empty ceremony):
> ## Why
> Login was silently failing for users with expired sessions — they'd click "Sign in" and nothing happened, no error. This restores the redirect to the login page.
>
> ## What changed
> `AuthGuard` now checks token expiry before rendering and pushes to `/login` when it's stale, instead of swallowing the 401.

## Principle 2: Assume the reader has zero context

The reviewer wasn't in your head, your standup, or the incident channel. Spell out the acronyms, the ticket's actual problem, the thing "everyone knows."

**Before:**
> Fixes the ISR bug from the incident. Bumps revalidate per the thread.

**After:**
> Our marketing pages use Next.js ISR (incremental static regeneration) with a 60s `revalidate`. During Tuesday's traffic spike, stale prices showed for up to a minute. This drops `revalidate` to 5s on the pricing route so price changes propagate quickly.

## Principle 3: Short, well-written paragraphs

Two or three tight sentences per idea. A wall of text is as unread as an empty template. Bullets only when they're genuinely clearer than prose.

**Before:**
> This change refactors the notification system which was previously handling everything in a single service that had grown to over 2000 lines and was responsible for email, SMS, and push all at once making it hard to test and reason about so I split it into three services each with its own queue and retry logic and also added a shared interface...

**After:**
> The notification service had grown to ~2,000 lines handling email, SMS, and push in one place — hard to test, hard to reason about.
>
> This splits it into three services behind a shared `Notifier` interface, each with its own queue and retry logic.

## Principle 3.5: Never hard-wrap paragraphs

GitHub renders a single newline inside a paragraph as a literal `<br>`. So if you manually wrap prose at ~72 or ~80 columns — the way you might in a code comment or commit body — every wrap point becomes a visible, broken-looking line break mid-sentence.

Write each paragraph as **one continuous line**. Same for each bullet. Use blank lines only to separate paragraphs, list items, and headings. Let the browser wrap the text.

**Before** (hard-wrapped at ~72 cols — renders with ragged mid-sentence breaks):
> Navigating between two different layouts could leave the previous layout
> stranded in the DOM — most visibly, the old header stuck around behind
> the new page.

**After** (one line per paragraph — wraps cleanly in any viewport):
> Navigating between two different layouts could leave the previous layout stranded in the DOM — most visibly, the old header stuck around behind the new page.

## Principle 4: Screenshots — only when the change is visible

If the change affects UI or visible output, a before/after image makes the diff legible at a glance. If it doesn't (backend, refactor, config), no screenshot — and no empty "Screenshots" heading either.

**Visible change — include it:**
> ## Screenshots
> Empty state used to be a blank panel; now it explains what goes here.
> | Before | After |
> | --- | --- |
> | ![blank panel](before.png) | ![helpful empty state](after.png) |

**Non-visible change — omit entirely:** a query-optimization PR has nothing to show. Don't add "Screenshots: N/A."

## Principle 5: Concrete testing cases

Tell the reviewer how to convince themselves it works: the specific input and the observed result, or the steps to reproduce.

**Before:**
> Tested and works.

**After:**
> - `POST /orders` with a negative quantity now returns 422 (was 500). Verified with `curl -d '{"qty":-1}'`.
> - Existing valid orders still return 201 — ran the `orders_api_test` suite, all green.

## Principle 6: Don't fill a section for the sake of it

Every section must earn its place. "Notes: none", "Testing: N/A", "Risks: low" are noise that trains reviewers to skim. Cut them.

**Before:**
> ## Notes
> None.
> ## Risks
> Low.

**After:** _(both sections simply deleted)_

## Full worked example

A complete description for a small, non-visible bug fix — note there are no Screenshots or Notes sections because they'd add nothing:

```markdown
## Why

Users on the free plan could exceed their 100-row export limit by opening
two exports in different tabs at once. The limit was checked in the UI but
never enforced on the server, so the second request slipped through.

## What changed

Moved the row-count check into the `/export` handler so it's enforced
server-side regardless of how the request is made. The UI check stays as a
fast pre-check, but it's no longer the only gate.

## Testing

- Two concurrent exports of 80 rows each (160 total) on a free account: the
  second now returns 403 with `export_limit_exceeded`. Previously both succeeded.
- Paid account exporting 5,000 rows: unaffected, still 200.
- Ran `export_limits_test` — all passing.
```
