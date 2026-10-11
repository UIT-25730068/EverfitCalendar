# EverfitCalendar

iOS take-home: a Monday–Sunday training calendar that loads workouts from a mock API, caches them locally, and lets the user mark assignments complete.

## Requirements

- Xcode 16.1
- iOS 18.1 deployment target
- No third-party packages

## Build & run

1. Open `EverfitCalendar.xcodeproj` in Xcode 16.1.
2. Select the **EverfitCalendar** scheme.
3. Run on an iPhone simulator (portrait) or iPad simulator (portrait and landscape).
4. Unit tests: **Product → Test**, or:

```bash
xcodebuild -project EverfitCalendar.xcodeproj -scheme EverfitCalendar \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:EverfitCalendarTests test
```

## Architecture

MVVM + Repository. One screen, no coordinator.

```
CalendarViewController  →  CalendarViewModel (@MainActor)
                               ↓
                         WorkoutsRepository
                    ↙          ↓           ↘
         WorkoutsAPIClient  WorkoutsCache  CompletionStore
         (async/await)      (actor/JSON)   (actor/JSON)
```

- **View:** programmatic UIKit + Auto Layout. `Main.storyboard` is only the entry host.
- **ViewModel:** week dates, load/retry, in-memory overrides, maps DTOs through `WorkoutStatusResolver`.
- **Domain:** `CalendarWeekFactory` (always Monday-start), `WorkoutMapping`, pure status rules.
- **Data:** DTOs stay separate from `Workout` / `CalendarDay`. Networking uses `URLSession` and `async/await`.

## Caching

Two files in the app Documents directory:

| File | Role |
|---|---|
| `workouts_cache.json` | Last **valid** API payload |
| `completion_overrides.json` | Local completion by assignment `_id` |

Warm launch: read cache + overrides first and **show those cards immediately**, then fetch updates in the background. `workoutStack` is hidden only when there is no local payload (empty date rows, like `Empty_Training.png`). If cache exists, cards stay visible during refresh and after mark/unmark. A successful 2xx decode **replaces** the payload cache. Overrides are **not** wiped on refresh. Invalid HTTP / decode failures never overwrite a good payload file. Bundled `workouts_fallback.json` is last-resort in-memory data only (not written as a server cache).

## Error handling

Typed `WorkoutsError` preserves underlying `URLError` / `DecodingError` for logs. The UI never shows raw technical strings.

| Situation | UI |
|---|---|
| First load in flight, no cache | Dates only (`workoutStack` hidden) + spinner |
| Cache hit, refresh in flight | Cached cards stay visible |
| Network fail + valid cache | Keep cache, no banner |
| No cache, API and fallback fail | Seven date rows + “Couldn't load workouts.” + **Retry** |
| Cancellation | Previous state unchanged |

Retry is only shown for the empty failure case. Tapping it returns to `initialLoading`.

## Display status

Display status is **derived** from calendar date vs today plus `isCompleted` (not raw API ints):

- Past incomplete → Missed  
- Past/today complete → Completed (checkmark)  
- Today incomplete → Assigned  
- Future → grey, no status text, **not tappable**

API `status == 2` is treated as a completed **seed** (`APIAssignmentCompletion`). That mapping is inferred from the mock (Tuesday “Full warm up workout”) and is isolated if the spec is confirmed later.

## Product notes

- Week is the **device’s current** Monday–Sunday in the local time zone, independent of `Calendar.firstWeekday`.
- Completions are local only (no PATCH).
- iPhone: portrait. iPad: portrait and landscape; content caps at 720pt and stays centered.

## AI Collaboration

**Tools:** Cursor (IDE + agent) with the in-editor model for architecture, UIKit layout, concurrency, and tests.

**How AI was used:** scaffolding UIKit views, Codable DTOs, `URLProtocol` tests, and JSON cache actors. Data flow, merge rules, and status resolution were specified first and then implemented, not generated as a black-box app.

**Example prompts (non-trivial):**

1. *“From Everfit_Mobile_Test Guide.pdf, list mandatory vs optional requirements, screens, and a one-day MVVM + Repository plan. Do not write code yet.”*
2. *“Implement CalendarWeekFactory so the week always starts Monday even when Calendar.firstWeekday is Sunday. Inject date and calendar for tests.”*
3. *“Add actor-backed JSON caches for the API payload and completion overrides. Cache-first load, never overwrite a valid cache with a failed response, keep overrides across refresh.”*

Complex date math and merge logic is owned and adjusted in-repo (Monday-start formula, override-wins mapping).

## Video walkthrough

Add your 3–5 minute Loom / Zoom / screen recording here:

**Video:** _paste public link_

Walkthrough should cover: why MVVM + Repository, API → cache → ViewModel → UI, local completion overrides, and how AI sped up boilerplate without replacing design decisions.

## Feature workflow (bonus)

Typical path for a new feature: clarify the contract (API + Figma) → isolate domain rules so they can be tested without UI → thin repository with explicit cache/error policy → ViewModel state machine (`initialLoading` / `refreshing` / `loaded` / `failedEmpty`) → pixel pass last → tests on the rules, not the pixels → README/video for handover.

## License

Take-home assignment; not for production use.
