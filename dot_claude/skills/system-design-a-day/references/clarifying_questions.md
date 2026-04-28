# Clarifying Questions Checklist

Reference for phase R (Requirements exploration) of the RADIO framework.
Treat each question as a **filter that narrows the solution space** — not a
formality. Every answer should eliminate or enable whole categories of design
decisions.

The goal isn't to ask all of them every time. Develop the instinct for which
matter for *this* problem.

---

## The 8 Questions

### 1. Who is the user base?

- **Why it matters**: Users in low-bandwidth regions need aggressive payload
  optimization; consumer apps skew mobile-first; internal tools can assume
  latest Chrome. Anonymous vs. authenticated changes caching.
- **Filtering effect**: Anchors every downstream perf/network choice. If
  "global mobile web users in emerging markets," you just bought
  code-splitting, image optimization, and offline as hard requirements.

### 2. What's the scale? (DAU / concurrent users / data volume)

- **Why it matters**: 1k DAU vs. 1B DAU changes almost nothing on the client
  *per user*, but it changes everything about your server assumptions, cache
  strategies, and whether you need CDN/edge caching. For UI components,
  scale often means "how many items on screen" — 20 rows vs. 100k rows
  switches you into virtualization territory.
- **Filtering effect**: Drives need for virtualization, pagination,
  infinite scroll, and whether you can fetch all data upfront.

### 3. What platforms / devices must we support?

- **Why it matters**: Desktop-only lets you assume hover + keyboard and a big
  viewport. Adding mobile means touch targets (44px+), no hover,
  bandwidth-conscious rendering, and often a completely different layout.
  Native mobile (if in scope) changes the deployment story.
- **Filtering effect**: Mobile support forces responsive design into phase A.
  "Web only desktop" simplifies the scope dramatically.

### 4. Do we need offline support?

- **Why it matters**: Offline shifts you into local-first architectures.
  You need a client-side store (IndexedDB), service workers, sync-on-reconnect
  logic, and conflict resolution when two offline sessions edit the same data.
- **Filtering effect**: Yes → service worker + client store become mandatory
  in phase A. No → you can assume network availability and skip a lot.

### 5. What are the performance targets?

- **Why it matters**: "Feels fast" is not a target. Named budgets — LCP < 2.5s,
  INP < 200ms, bundle < 170KB — drive concrete technique choices.
- **Filtering effect**: Tight LCP budget → SSR / streaming / edge rendering.
  Tight INP → virtualization + input debouncing + work offloading. Loose
  budgets mean you can lean on the simplest approach.

### 6. Is the data real-time, near-real-time, or eventual?

- **Why it matters**: Real-time (chat, collab docs) demands WebSocket/SSE +
  optimistic UI + reconciliation on conflict. Near-real-time (social feeds)
  can use polling or pull-on-focus. Eventual (dashboards) can refresh on
  interval or route change.
- **Filtering effect**: Picks the protocol in phase I. Real-time forces a
  whole concurrency-and-sync story in phase O.

### 7. What's the authentication/authorization model?

- **Why it matters**: Public-only content is simpler; user-authenticated
  content changes caching (per-user cache keys, cannot use shared CDN
  aggressively); multi-tenant changes data scoping everywhere.
- **Filtering effect**: Auth-gated pages cannot be cached at the CDN the same
  way. Permission models affect API design in phase I and data fetching
  patterns in phase A.

### 8. What's core vs. good-to-have?

- **Why it matters**: You *cannot* design the whole product in 45 minutes.
  This question forces explicit prioritization and gives you permission to
  say "I'm not going to design X."
- **Filtering effect**: Marks the scope line. Everything good-to-have gets
  one sentence in phase O and no more.

---

## Using this checklist in practice

- **Standard mode**: ask 3–5 of these, not all 8. Pick the ones the problem
  signals most strongly.
- **Deep mode**: the rubric scores your coverage. Missing a question that
  matters for this problem is a graded miss.
- **After each question**, state back what you just learned: "OK, so we're
  global mobile-first with tight bandwidth — that means I'll prioritize
  bundle size and image optimization in my deep dive."

That last move — narrating what the answer *means* for your design — is the
signal interviewers are looking for. Asking the question isn't enough.
