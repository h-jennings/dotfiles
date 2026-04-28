# Curriculum — Front-End System Design

Progression map for daily practice. Two problem tracks (UI Components,
Applications) plus a Concepts tier of reusable building blocks.

Sourced primarily from the GreatFrontend case-study catalog. Topics are
ordered roughly by complexity within each track.

---

## UI Components Track

Start here if new to front-end system design. Scoped problems teach the
RADIO cadence with a smaller surface area.

### Easy (Weeks 1–2)

#### Modal Dialog
- **Focus areas**: Focus trap, accessibility (ARIA roles, focus return),
  portal rendering, keyboard handling (Esc to close), backdrop click behavior.
- **Prereq**: none.

#### Dropdown Menu
- **Focus areas**: Positioning (collision detection, portal), keyboard nav
  (arrow keys, type-to-search), a11y (combobox/menu patterns), click-outside.
- **Prereq**: none.

### Medium (Weeks 2–4)

#### Image Carousel
- **Focus areas**: Lazy loading, preload strategy, touch gestures, keyboard
  nav, infinite loop semantics, a11y (live regions, alt text).
- **Prereq**: Modal (portal + keyboard patterns).

#### Poll Widget
- **Focus areas**: Optimistic vote submission, result reveal animation,
  anti-abuse (one vote per user), real-time result updates (polling vs.
  WebSocket).
- **Prereq**: Dropdown (component API design).

#### Autocomplete
- **Focus areas**: Debounced fetching, request cancellation (AbortController /
  race condition handling), keyboard nav, result caching, a11y (combobox
  pattern).
- **Prereq**: Dropdown, Modal.

### Hard (Weeks 4–6)

#### Data Table
- **Focus areas**: Virtualization, sort/filter/paginate tradeoffs (client vs.
  server), column resizing, sticky headers, a11y (table semantics, keyboard
  nav at scale), i18n (number/date formatting).
- **Prereq**: Autocomplete, Image Carousel.

#### Rich Text Editor
- **Focus areas**: ContentEditable vs. custom renderer, document model
  (operations, commands), undo/redo stack, serialization (HTML/Markdown/JSON),
  collaboration (OT/CRDT for multi-user).
- **Prereq**: Data Table (document model thinking).

---

## Applications Track

Start these after completing at least 2–3 UI Components. Full-app problems
demand broader architectural thinking.

### Medium (Weeks 4–7)

#### News Feed (Twitter / Facebook)
- **Focus areas**: Infinite scroll + virtualization, feed ranking (if
  in-scope), optimistic compose, real-time updates (new-post banner), image
  handling, cache invalidation.
- **Prereq**: Autocomplete, Data Table.

#### E-commerce Product Page (Amazon)
- **Focus areas**: Image gallery, variant selection, cart state (local vs.
  server), reviews pagination, perf (LCP on hero image), SEO/SSR.
- **Prereq**: Image Carousel, News Feed.

#### Photo Sharing (Instagram)
- **Focus areas**: Upload pipeline (resize, EXIF, progress), infinite feed,
  stories ephemeral UX, offline queue, CDN strategy.
- **Prereq**: News Feed.

### Hard (Weeks 7–10)

#### Chat / Messenger
- **Focus areas**: WebSocket protocol design, message ordering, optimistic
  send + confirm/fail, offline queue, read receipts, typing indicators,
  reconnect semantics.
- **Prereq**: News Feed.

#### Video Streaming (Netflix)
- **Focus areas**: HLS/DASH adaptive bitrate, player state machine,
  prefetching, buffering heuristics, DRM boundary, recommendations rail
  perf.
- **Prereq**: News Feed, Data Table.

#### Email Client (Outlook / Gmail)
- **Focus areas**: Three-pane layout, threaded conversations, search,
  keyboard shortcuts (gmail-style), offline + sync, attachment handling.
- **Prereq**: Chat, Data Table.

### Very Hard (Weeks 10+)

#### Collaborative Docs (Google Docs)
- **Focus areas**: OT vs. CRDT choice, cursor/presence broadcasting, offline
  edits + sync, comments layer, suggestion mode, undo semantics under
  collaboration.
- **Prereq**: Rich Text Editor, Chat.

#### Video Conferencing (Zoom)
- **Focus areas**: WebRTC signaling, ICE/STUN/TURN, SFU vs. MCU, adaptive
  quality, screen share, recording pipeline, layout engine (speaker/gallery).
- **Prereq**: Chat.

#### Travel Booking (Airbnb)
- **Focus areas**: Search UX with filters + map, calendar availability,
  payment flow, image-heavy listing page perf, i18n (currency, language,
  dates).
- **Prereq**: E-commerce, Data Table.

---

## Concepts Tier

Building blocks that show up across problems. Teach on demand when a problem
exposes a gap, or proactively before the first problem that needs it.

### Architecture & State

- **Unidirectional Data Flow (MVC / Flux / Redux)** — prereq for any app
  problem.
- **Client-Side State Management** — local state, context, global stores,
  server cache (React Query / SWR).
- **Component Architecture** — composition, controlled vs. uncontrolled,
  compound components, render props / children-as-function.

### Network

- **REST vs. GraphQL vs. tRPC** — when to pick which.
- **WebSocket / SSE / Long Polling** — real-time protocol tradeoffs.
- **HTTP Caching** — Cache-Control, ETag, stale-while-revalidate.
- **Service Workers** — cache strategies, offline, background sync.

### Rendering

- **CSR / SSR / SSG / ISR** — tradeoffs and when to reach for each.
- **Hydration & Streaming** — React Server Components, progressive hydration.
- **Virtualization** — windowing for long lists (react-window / virtuoso).

### Performance

- **Critical Rendering Path** — LCP, FCP, TTI, INP, CLS.
- **Bundle Optimization** — code splitting, tree shaking, dynamic import.
- **Image & Asset Delivery** — responsive images, AVIF/WebP, CDNs, priority
  hints.

### Cross-cutting

- **Accessibility** — ARIA patterns, focus management, screen reader testing.
- **Internationalization** — locale detection, message formatting, RTL, text
  expansion.
- **Security (Front-End)** — XSS, CSRF, CSP, sanitization, auth/session
  handling.
- **Offline & Sync** — local-first architecture, conflict resolution,
  IndexedDB.
