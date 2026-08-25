Write the git commit message for the staged diff

Output only the commit message. No explanation, no code fence, no preamble.

## Header

`type(scope): subject`

- `type` is lowercase, one of: build, chore, ci, docs, feat, fix, perf,
  refactor, revert, style, test. Nothing else.
- The subject's first character is lowercase. Worth care: `Add the helper`
  fails, and so does `NetSuite lines now post`, because a leading capital reads
  as sentence-case. Rephrase so a lowercase word leads. Capitals later are fine
  -- `let Escape close the popup` passes.
- No trailing period.
- The whole header is at most 100 characters, ticket reference included.

Pick the type from what the diff touches: `test` when only test files change,
`chore(deps)` for dependency bumps, `refactor` when behaviour is unchanged,
`fix` for a defect, `feat` for new behaviour.

`scope` is the feature area, lowercase, usually one word. Infer it from the
diff's paths. Omit it when the change spans areas or is repo-wide -- a bare
`feat: ...` is common and correct.

## Body

One blank line after the header. Then, in order of what matters:

**Lead with why, not what.** The first sentence is the situation that made this
change necessary, in terms a reader outside your head would recognise. `Login
was silently failing for users with expired sessions -- they'd click "Sign in"
and nothing happened, no error` beats `Fixes the auth bug`. The diff already
says what changed; the body says why it had to.

**Assume the reader has zero context.** They were not in the standup or the
incident channel. Spell out acronyms and name the actual problem. `Fixes the
ISR bug from the incident` tells them nothing; `Our marketing pages use Next.js
ISR (incremental static regeneration) with a 60s revalidate, so stale prices
showed for up to a minute during Tuesday's spike` tells them everything.

**Short, well-written paragraphs.** Two or three tight sentences per idea. A
wall of text goes unread as surely as no body at all. Use bullets only where
they are genuinely clearer than prose -- a list of independent, parallel
changes. Do not default to them: a bulleted restatement of the diff is the
thing to avoid.

**Hard-wrap at 90 columns.** Deliberately unlike a PR description, where a
manual newline renders as a broken `<br>`. A commit body has no browser to wrap
it.

**Say nothing the diff does not support.** You are working from a diff alone, so
you cannot see the discussion behind it. Never cite a PR number, a date, a
meeting, a prior commit, a ticket, or a rejected alternative you cannot see in
front of you -- a plausible but wrong `since #2680` does more damage in a commit
than a missing sentence. Where the reasoning is not in the diff, leave it for
the author.

**Be concrete where you can be.** Name the identifier, the path, the endpoint,
the status code, in backticks. `the second request now returns 403 with
export_limit_exceeded` earns its place; `improved error handling` does not.

**Nothing filler.** No body at all is better than a body restating the subject.
A dependency bump or a formatting pass needs no body -- stop at the header.

## Footer

Usually none. Only when the diff itself shows a breaking change: a blank line,
then `BREAKING CHANGE: <what breaks and what callers should do>`.
