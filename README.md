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

**Tools:** Cursor (IDE + AI agent), using the in-editor model to support architecture planning, UIKit implementation, concurrency, and testing.

**How AI was used:** AI assisted with UIKit scaffolding, Codable DTOs, URLProtocol-based network tests, and actor-backed JSON caching. I defined the data flow, merge rules, and workout status logic before implementation, then reviewed and validated the generated code rather than treating AI as a black-box app generator.

**One-day development workflow:**

1. *Analyze requirements and plan: Identify mandatory requirements, clarify business rules, and define the MVVM + Repository architecture.*

2. *Build the calendar UI: Implement the Monday–Sunday date calculation, responsive UIKit layout, and workout card states.*

3. *Integrate data and business logic: Add API networking, DTO-to-domain mapping, workout status resolution, and local completion toggling.*

4. *Add persistence and error handling: Implement cache-first loading, local completion overrides, fallback behavior, and retry handling.*

5. *Test, review, and polish: Verify date boundaries, status rules, caching, failure scenarios, and UI behavior; fix issues and prepare the README and demo video.*

**Example prompts (non-trivial):**

1. *“From Everfit_Mobile_Test Guide.pdf, identify mandatory vs. optional requirements, required screens, and a one-day MVVM + Repository implementation plan. Do not write code yet.”*

2. *“Implement CalendarWeekFactory so the week always starts on Monday, regardless of Calendar.firstWeekday. Inject the calendar and reference date to make the logic testable.”*

3. *“Implement actor-backed JSON storage for the API payload and local completion overrides. Load cached data first, never replace a valid cache with a failed response, and preserve local overrides across refreshes.”*

Complex date calculations and data-merging behavior were reviewed and refined in the codebase, especially the Monday-start week calculation and the rule that local completion overrides take precedence over API data.

## Video walkthrough

Add your 3–5 minute Loom / Zoom / screen recording here:

**Video:** _paste public link_

Walkthrough should cover: why MVVM + Repository, API → cache → ViewModel → UI, local completion overrides, and how AI sped up boilerplate without replacing design decisions.

## Feature workflow (bonus)

Typical path for a new feature: clarify the contract (API + Figma) → isolate domain rules so they can be tested without UI → thin repository with explicit cache/error policy → ViewModel state machine (`initialLoading` / `refreshing` / `loaded` / `failedEmpty`) → pixel pass last → tests on the rules, not the pixels → README/video for handover.

## License

Take-home assignment; not for production use.
