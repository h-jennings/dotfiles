# The RADIO Framework

Authoritative reference for every practice session. Adapted from the
GreatFrontend Front-End System Design Playbook.

RADIO is a time-boxed, structured approach to front-end system design
interviews. Each letter is a phase. Treat the time allocations as interviewer
expectations — spending 80% of the session on Requirements signals bad time
management, even if the requirements are great.

---

## Summary

| Phase | Name                          | Time    | Output                                         |
|-------|-------------------------------|---------|------------------------------------------------|
| R     | Requirements exploration      | <15%    | Functional + non-functional requirements list  |
| A     | Architecture / high-level     | ~20%    | Component diagram + responsibilities           |
| D     | Data model                    | ~10%    | Entity table (fields, source, owner)           |
| I     | Interface definition (API)    | ~15%    | APIs: name, params, response                   |
| O     | Optimizations and deep dive   | ~40%    | Deep dive on 2–4 critical axes                 |

---

## R — Requirements exploration

**Objective**: understand the problem thoroughly and determine scope through
clarifying questions. The candidate's goal is to *narrow* the problem before
solving it.

### Questions to ask (mandatory toolkit)

1. **What are the main use cases?** Pick the most unique/defining product
   features. Don't try to cover everything.
2. **Functional vs. non-functional requirements?**
   - Functional: core flows that must work.
   - Non-functional: perf, scale, a11y, i18n, offline.
3. **Core features vs. good-to-have?** Explicitly deprioritize the
   good-to-haves; don't design them.
4. **Platform support?** Desktop, mobile web, mobile native? Responsive?
5. **Offline support?** Yes → service worker, local-first sync strategy.
6. **User base?** Who they are, how many, where geographically.
7. **Performance requirements?** TTI / LCP / INP targets, payload budgets.

Full checklist with filtering rationale is in `clarifying_questions.md`.

### Deliverable

A bullet list of functional + non-functional requirements, plus explicit
**in-scope** / **out-of-scope** markers. State what you're *not* designing.

---

## A — Architecture / high-level design

**Objective**: identify the key components and how they connect.

### Standard component set

- **Server** — black-box APIs (HTTP / WebSocket / SSE).
- **View** — what the user sees. Often decomposed into subviews.
- **Controller** — responds to user interactions; transforms data for views.
- **Model / Client Store** — where client-side data lives (in-memory, cache,
  IndexedDB).

### Design considerations

- **Separation of concerns** — each component owns one responsibility.
- **Where computation happens** — client vs. server tradeoffs. Pushing work
  to the server costs latency; keeping it on the client costs battery and
  bundle size.
- **Unidirectional data flow** — for React/Vue-style apps, state flows down,
  events flow up. State mutations go through a single pathway.

### Deliverable

A **diagram** (ASCII or mermaid) of boxes with arrows showing data flow, plus
one sentence per component stating its responsibility. If this phase ends
without a diagram, the candidate has failed this phase.

---

## D — Data model

**Objective**: describe the entities, their fields, and which component owns
them.

### Data categorization

1. **Server-originated data** — authored by the backend, shared across users.
   Profiles, posts, comments, feed items.
2. **Client-only persistent** — user input headed to the server (draft post,
   form state).
3. **Client-only ephemeral** — UI state, nuked on refresh (open/closed panel,
   which tab is active, validation in progress).

### Deliverable

A table:

| Entity | Fields                  | Source | Owner (component)  |
|--------|-------------------------|--------|---------------------|
| Post   | id, author, body, likes | server | Client Store (cached) |
| Draft  | body, attachments       | client | Composer View      |

Keep it tight. 5–8 entities for an application, 2–4 for a UI component.

---

## I — Interface definition (API)

**Objective**: specify the interfaces between components. Every API has three
elements:

1. **Name + functionality** — what it does, one sentence.
2. **Parameters** — HTTP query/body for server APIs; function args for client APIs.
3. **Return value** — response schema or return type.

### API categories

- **Server ↔ client** — HTTP methods + paths + JSON schemas. Consider REST vs.
  GraphQL tradeoffs. For real-time: WebSocket / SSE events.
- **Client ↔ client** — JS function signatures, event shapes, prop contracts.
- **UI component props** — for component problems, this is the main deliverable.

### Deliverable

For each major API, show:

```
GET /feed?cursor=<id>&limit=20
→ { items: Post[], nextCursor: string | null }
```

---

## O — Optimizations and deep dive

**40% of the session lives here — this is where the grade is earned.**

**Objective**: go deep on 2–4 axes that matter most for *this* product. Don't
try to cover all of them. Pick based on the requirements from phase R.

### Deep-dive axes

- **Performance** — bundle size, code-splitting, lazy loading, virtualization,
  render perf, LCP / INP / CLS.
- **Network** — caching (HTTP / SW / in-memory), prefetch, batching,
  compression, request deduplication, optimistic updates.
- **User experience** — loading skeletons, error states, empty states,
  optimistic UI, micro-interactions.
- **Accessibility** — semantics, ARIA, keyboard nav, focus management, screen
  readers, color contrast.
- **Internationalization** — RTL layouts, locale-aware formatting, text
  expansion handling.
- **Multi-device / responsive** — breakpoints, touch targets, variable
  network conditions.
- **Security** — XSS, CSRF, auth/session, rate limiting, secure headers.

### How to pick axes

- A **Dropdown** problem deep-dives on accessibility + keyboard navigation.
- A **News Feed** problem deep-dives on infinite scroll perf + network caching.
- A **Chat App** problem deep-dives on real-time sync + offline + optimistic UX.
- A **Google Docs** problem deep-dives on concurrency (CRDT / OT) + persistence.

### Deliverable

For each chosen axis: a concrete plan with 2–3 specific techniques, each with
a one-line rationale tied back to the requirements.

---

## Tradeoff discipline

Throughout every phase, name the alternative and explain why you chose this
one. "I'd use React Query here" is weak. "I'd use React Query over hand-rolled
fetch because we need request deduplication and stale-while-revalidate — the
product's requirement for instant-feeling navigation makes cache-first worth
the bundle-size hit" is strong.
