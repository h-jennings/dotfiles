# Writing for the ear

Prose written for reading fails when spoken. The reader controls the pace, re-reads a clause, skips ahead, sees the structure on the page. The listener has none of that. Every rule below follows from that one difference.

## Sentences

**One idea per sentence.** Subordinate clauses that read fine ("the handler, which was previously in the middleware layer that we removed last sprint, now validates inline") collapse by ear. Split them: "The handler used to live in the middleware. We deleted that layer. It validates inline now."

**Front-load.** The listener decides in the first four words whether to keep paying attention. Put the claim first and the qualification second — "This will break under concurrent writes, though only above a few hundred a second," never the reverse.

**Vary sentence length.** Uniform medium-length sentences turn into a drone that the ear stops parsing. A three-word sentence after a long one resets attention. Like that.

**Prefer verbs to nominalizations.** "Validation of the token occurs" → "it validates the token." Nominalized prose is heavy to read and nearly opaque to hear.

**Cut throat-clearing.** "It's worth noting that," "I should mention," "as we can see." Every one of these is a second of the listener's life spent on nothing.

## Structure the listener can hold

**Signpost with numbers, sparingly.** "Three things here." Then "First… Second… Third…" A listener will hold three items. They will not hold seven — if you have seven, you have a written document, not a brief.

**Announce transitions.** Headings are invisible in audio. "That's the mechanism — now the part that worries me" does the work a heading would.

**Repeat the load-bearing idea.** Not verbatim; rephrased. If one thing must survive the brief, say it at the top, develop it in the middle, and land it at the end. This feels redundant on the page and correct in the ear.

**End on the action.** The last sentence is the most retained. Spend it on what the user should do or look at, never on a summary of what you just said.

## Things that must not reach the audio

| Don't say | Say instead |
|---|---|
| `useEffect(() => {...}, [config])` | "the effect that watches config" |
| `src/api/handlers/upload.ts:142` | "in the upload handler" (they'll find it) |
| "line 47 through 63" | "the new early-return block" |
| `snake_case`, `camelCase` spelled out | the concept the name refers to |
| "PR #1284" | "this PR" |
| Bullet lists read as bullets | prose with spoken connectives |
| Version strings, hashes, UUIDs | "the pinned version," "that commit" |

The exception is a name short and pronounceable enough to work as a word — "the `retry` helper" is fine. Two-word identifiers usually survive; anything with punctuation in it does not.

## Numbers and names

Spell out what a reader would parse silently: "about eighteen hundred lines," not "1,847 LOC." Round aggressively — precision the listener can't write down is noise. Say acronyms the way you'd say them out loud, and expand any the user might not know on first use.

## Tone

Talk like a colleague who read the code and walked over to your desk. Contractions, plain words, a stated opinion. Confidence should track your actual confidence — the ear reads flat delivery as certainty, so hedges have to be explicit and in the words themselves: "I'm not sure this matters, but…"

Avoid enthusiasm the material doesn't earn. Spoken hype is far more grating than written hype, because the listener can't skim past it.

## Length budget

At ~150 words per minute:

| Words | Runtime | Good for |
|---|---|---|
| 100 | 40s | one finding, a quick heads-up |
| 250 | 100s | a focused review or explainer |
| 400 | 2m40s | a full diff walkthrough, a digest |
| 600+ | 4m+ | too long — split it or cut scope |

If the material doesn't fit, drop the least important section entirely. Compressing everything uniformly produces a brief that is dense, fast, and impossible to follow.

## The read-aloud test

Before generating, read the script out loud — actually out loud. Every place you stumble, run out of breath, or have to back up is a place the listener will lose the thread. Fix those, then generate.
