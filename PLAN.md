# Plan: FocusPoints & TrainingTypes

## Overview

Replace the hardcoded sport-type strings and free-text focus-point field with two new managed domain models — `FocusPoint` and `TrainingType` — that users create, edit, and maintain from the Profile page. The `TrainingSession` model will reference these objects instead of raw strings. Inline creation during session form entry is supported when no options exist yet. The architecture must be ready for a future database backend.

---

## 1. New Models

### 1.1 `FocusPoint`

A goal or theme a user wants to work on over a defined period.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Unique identifier |
| `title` | `String` | Short label, e.g. *"Improve running cadence"* |
| `description` | `String?` | Optional longer explanation |
| `startDate` | `DateTime` | When this focus period begins |
| `endDate` | `DateTime` | When this focus period ends (e.g. +4 weeks) |
| `isActive` | `bool` | Quick toggle to archive/deactivate without deleting |
| `color` | `int?` | Optional hex colour for UI accent (e.g. status dot) |
| `createdAt` | `DateTime` | |
| `updatedAt` | `DateTime?` | |

**Validation:** `endDate` must be strictly after `startDate`. `title` must be non-empty and unique among active focus points.

**Location:** `lib/modules/focus/models/focus_point.dart`

### 1.2 `TrainingType`

A user-defined sport or activity category (replaces the hardcoded list).

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Unique identifier |
| `name` | `String` | Display name, e.g. *"Trail Running"*, *"Bouldering"* |
| `icon` | `IconData?` | Optional icon identifier for UI |
| `iconCodePoint` | `int?` | Material Icon code point for DB-friendly serialization |
| `color` | `int?` | Optional hex colour (stored as int) for UI accents |
| `createdAt` | `DateTime` | |

**Icon serialization:** Store the icon as `int? iconCodePoint` in the model. Provide a helper getter `IconData? get icon => iconCodePoint != null ? IconData(iconCodePoint, fontFamily: 'MaterialIcons') : null;` for UI consumption. This keeps the model DB-friendly while remaining usable in widgets.

**Location:** `lib/modules/training_type/models/training_type.dart`

### 1.3 Migrate `TrainingSession.focusPoint`

Change the existing `focusPoint` field from `String?` to `FocusPoint?` (a direct reference to the chosen focus point). This links a session to its parent goal.

### 1.4 `TrainingSession.sportType` → `TrainingSession.trainingType`

Replace the `sportType` (`String`) field with a `trainingType` field of type `TrainingType?` (nullable so that a type-less session is still valid for backwards compatibility, though the form should require it).

---

## 2. Stores (In-Memory → DB-Ready)

Two new in-memory stores follow the same pattern as `SessionStore`:

| Store | Responsibility | Location |
|---|---|---|
| `FocusStore` | CRUD for `FocusPoint` objects | `lib/modules/focus/focus_store.dart` |
| `TrainingTypeStore` | CRUD for `TrainingType` objects | `lib/modules/training_type/training_type_store.dart` |

Each store must extend `ChangeNotifier` (or use a stream) so widgets can react to data changes:

```dart
class FocusStore extends ChangeNotifier {
  final List<FocusPoint> _items = [];
  List<FocusPoint> get all => List.unmodifiable(_items);
  
  void add(FocusPoint entity) { _items.add(entity); notifyListeners(); }
  void update(FocusPoint entity) { /* find & replace */ notifyListeners(); }
  void remove(String id) { _items.removeWhere((e) => e.id == id); notifyListeners(); }
  FocusPoint? getById(String id) => _items.cast<FocusPoint?>().firstWhere((e) => e!.id == id, orElse: () => null);
}
```

**Cascade on delete:** When a `TrainingType` or `FocusPoint` is removed, iterate `SessionStore.all` and set the corresponding field to `null` on any matching session, then call `sessionStore.notifyListeners()`.

**Future DB note:** The stores will later be refactored to abstract behind a repository interface (e.g. `SessionRepository`, `FocusRepository`, `TrainingTypeRepository`). The in-memory implementations will become the test/mock implementations, and real DB implementations (Firestore, SQLite via drift, etc.) will swap in via dependency injection. For now, keep them as simple singleton stores (like `SessionStore`) to minimise churn.

**Shared singleton instances** (like `sessionStore`):
```dart
final SessionStore sessionStore = SessionStore();
final FocusStore focusStore = FocusStore();
final TrainingTypeStore trainingTypeStore = TrainingTypeStore();
```

---

## 3. Profile Page Redesign

The current `ProfilePage` is a placeholder. It needs to become the management hub for focus points and training types.

### 3.1 Layout

```
┌─────────────────────────────────┐
│          AppBar (Profile)       │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │   User info section       │  │
│  │   (avatar, name, email)   │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │   Training Types          │  │
│  │   [Show all] [+ Add]     │  │
│  │   ┌─────┐ ┌─────┐ ┌─────┐│  │
│  │   │Run  │ │Swim │ │Yoga ││  │
│  │   └─────┘ └─────┘ └─────┘│  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │   Focus Points            │  │
│  │   [Show all] [+ Add]     │  │
│  │   ┌─────────────────────┐ │  │
│  │   │ Improve cadence     │ │  │
│  │   │ Apr 1 – Apr 28 🟢  │ │  │
│  │   ├─────────────────────┤ │  │
│  │   │ Build endurance     │ │  │
│  │   │ May 1 – May 28 🔴  │ │  │
│  │   └─────────────────────┘ │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│   BottomAppBar (nav + FAB)     │
└─────────────────────────────────┘
```

### 3.2 Navigation Integration

The Profile page currently opens as a pushed route without a bottom nav. It should instead be added as a third tab in the `HomeScreen` bottom navigation, accessible from the main scaffold alongside Stats and Calendar. The person icon in the AppBar can remain as a shortcut to the profile tab, or be removed.

**Current nav tabs:** Stats, Calendar  
**New nav tabs:** Stats, Calendar, Profile

This means `HomeScreen` gets a third page and a third nav item in the `BottomAppBar`.

### 3.3 List Pages

The "Show all" buttons in each section navigate to:
- `ManageTrainingTypesPage` (`lib/modules/training_type/pages/manage_training_types_page.dart`) — a scrollable list with swipe-to-delete and tap-to-edit.
- `ManageFocusPointsPage` (`lib/modules/focus/pages/manage_focus_page.dart`) — same pattern, with an active/archived filter toggle.

Update the file tree to include these pages.

### 3.4 CRUD Dialogs / Sheets

- **Add/Edit TrainingType:** A bottom sheet with a name field, optional icon picker (limited set of predefined Material icons), optional colour picker. Validate that name is non-empty and unique.
- **Add/Edit FocusPoint:** A full-page or sheet form with title, description, start date, end date (duration picker like "4 weeks"), colour picker, and active toggle. Validate `endDate > startDate` and unique title among active items.

---

## 4. AddSessionPage Changes

### 4.1 Replace Sport Type Input

- Remove the hardcoded `_commonSportTypes` list.
- Replace `_sportTypeController` with a picker that lists all `TrainingType` objects from the `TrainingTypeStore`.
- Include a **"Create new type"** option at the bottom of the picker (or a small + button) that opens the same add-TrainingType sheet from the profile — on save, it appears in the store and is selected automatically.
- If the store is empty, show a prompt: *"No training types yet. Create one to get started."* and the same creation flow.

### 4.2 Replace Free-Text Focus Point

- Remove `_focusPointController` (free text).
- Add a dropdown/chip selector that lists all active `FocusPoint` objects from `FocusStore`.
- Include **"Create new focus point"** option that opens the add-FocusPoint form — on save, it becomes selected.
- If no focus points exist, show a similar empty-state prompt with inline creation.

### 4.3 Wire the New Model References

When saving a session:
```dart
TrainingSession(
  ...
  trainingType: selectedTrainingType,  // TrainingType object
  focusPoint: selectedFocusPoint,      // FocusPoint object|null
  ...
)
```

The `TrainingSession` model fields change as described in §1.3–1.4.

---

## 5. Stats Page Redesign

The current `StatsPage` is a placeholder. With the new models in place, it becomes the analytics hub for all training data.

### 5.1 Layout

```
┌─────────────────────────────────┐
│          AppBar (Stats)         │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │  📊 Overview              │  │
│  │  Total sessions:  42      │  │
│  │  This week:        5      │  │
│  │  This month:      18      │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  🏃 By Training Type     │  │
│  │  ┌───────┬──────┬─────┐  │  │
│  │  │ Type  │ Sess │ %   │  │  │
│  │  ├───────┼──────┼─────┤  │  │
│  │  │ Run   │  12  │ 29% │  │  │
│  │  │ Swim  │   8  │ 19% │  │  │
│  │  │ Yoga  │   6  │ 14% │  │  │
│  │  │ …     │   …  │  …  │  │  │
│  │  └───────┴──────┴─────┘  │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  🎯 By Focus Point       │  │
│  │  ┌──────────────────────┐ │  │
│  │  │ Improve cadence   12 │ │  │
│  │  │ Build endurance     8 │ │  │
│  │  │ Mobility focus      5 │ │  │
│  │  │ (No focus)         17 │ │  │
│  │  └──────────────────────┘ │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  📈 Score Distributions  │  │
│  │                           │  │
│  │  Focus          ████░░    │  │
│  │  0 1 2 3 4 5 6 7 8 9 10  │  │
│  │                           │  │
│  │  Frustration    ░████░    │  │
│  │  0 1 2 3 4 5 6 7 8 9 10  │  │
│  │                           │  │
│  │  Fatigue        ██░░██    │  │
│  │  0 1 2 3 4 5 6 7 8 9 10  │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│   BottomAppBar (nav + FAB)     │
└─────────────────────────────────┘
```

### 5.2 Data to Display

| Section | What it shows | Source query |
|---|---|---|
| **Overview** | Total sessions, this week/month counts, maybe a streak | `SessionStore.all` filtered by date ranges |
| **By Training Type** | Each type name, session count, percentage of total. Clicking a row could filter the calendar/session list to that type. | `groupBy(session.trainingType?.name ?? 'Uncategorised')` |
| **By Focus Point** | Each focus point title, session count. Includes an "(No focus)" row for sessions without one. | `groupBy(session.focusPoint?.title ?? 'No focus')` |
| **Score Distributions** | Three horizontal bar charts (one per score axis), each showing how many sessions scored 0–10. | `groupBy(session.focusScore)`, same for `frustrationScore` & `fatigueScore` |

### 5.3 Score Distribution Chart Details

Each of the three scores (focus, frustration, fatigue) gets its own chart. The X-axis is the score value 0–10, the Y-axis is the count of sessions at that score. Represented as horizontal bar rows (like a stacked row of segments) or a simple column chart using custom painted bars or a package like `fl_chart`.

**Simpler approach (no external dependency):** Render each distribution as a row of 11 coloured blocks whose widths are proportional to the count for that score value. This is purely custom `Container` + `Row` widgets and keeps the dependency list lean.

### 5.4 Interaction & Filtering

- Tapping a Training Type row could navigate to the Calendar page filtered to that type (pass the type ID as a route argument).
- Tapping a Focus Point row could show a list of sessions under that focus.
- Score distribution bars could be tappable to see which sessions had a particular score.

Phase 1 can skip deep-linking interactions and just show the static breakdowns. Phase 2 adds navigation hooks.

### 5.5 Stats Model

Introduce a lightweight helper class or computed methods (no separate store needed — the data is derived from `SessionStore` at runtime):

```dart
class TrainingStats {
  final List<TrainingSession> allSessions;

  int get totalSessions => allSessions.length;

  Map<String, int> sessionsByTrainingType() { … }
  Map<String, int> sessionsByFocusPoint() { … }
  Map<int, int> focusScoreDistribution() { … }
  Map<int, int> frustrationScoreDistribution() { … }
  Map<int, int> fatigueScoreDistribution() { … }
}
```

**Location:** `lib/modules/stats/models/training_stats.dart`

This keeps the stats computation testable and separate from widget code.

---

## 6. Migration of Existing Data

The mock sessions in `mock_sessions.dart` currently use raw strings. Since we're removing the hardcoded list, we need a migration strategy:

1. Seed default `TrainingType` objects for the most common existing sport types (Running, Swimming, Cycling, HIIT, Strength, Yoga, etc.) so the mock sessions can reference them.
2. Update each mock session to point to the matching `TrainingType` object by ID.
3. For `focusPoint`, the mock sessions currently have free-text strings. We can either:
   - Create corresponding `FocusPoint` objects and link them, or
   - Leave `focusPoint` as `null` for mock sessions (simpler, but loses demo data).

**Recommended approach:** Keep the mock `FocusPoint` free-text strings as a separate `mockFocusPoints` list, and regenerate the mock sessions to reference them by ID. This preserves the demo experience.

---

## 7. File Tree (New & Changed Files)

```
lib/
├── main.dart                                  # (unchanged)
├── app.dart                                   # CHANGED: add Profile tab
│
├── modules/
│   ├── focus/
│   │   ├── models/
│   │   │   └── focus_point.dart               # NEW
│   │   ├── focus_store.dart                   # NEW
│   │   └── pages/
│   │       └── manage_focus_page.dart         # NEW (optional, or inline in profile)
│   │
│   ├── training_type/
│   │   ├── models/
│   │   │   └── training_type.dart             # NEW
│   │   ├── training_type_store.dart           # NEW
│   │   └── pages/
│   │       └── manage_training_types_page.dart # NEW (optional)
│   │
│   ├── session/
│   │   ├── models/
│   │   │   └── training_session.dart          # CHANGED
│   │   ├── mock/
│   │   │   └── mock_sessions.dart             # CHANGED
│   │   ├── pages/
│   │   │   └── add_session_page.dart          # CHANGED
│   │   └── session_store.dart                 # (unchanged)
│   │
│   ├── profile/
│   │   └── pages/
│   │       └── profile_page.dart              # REWRITTEN
│   │
│   ├── training_type/
│   │   └── pages/
│   │       └── manage_training_types_page.dart # NEW
│   │
│   ├── focus/
│   │   └── pages/
│   │       └── manage_focus_page.dart         # NEW
│   │
│   ├── calendar/  …                           # (unchanged)
│   └── stats/  …                              # (unchanged)
│
└── core/
    ├── constants/
    │   └── app_constants.dart                 # (unchanged)
    └── theme/
        └── app_theme.dart                     # (unchanged)
```

---

## 8. Future Database Considerations

- All models should have `id` as `String` (UUID-compatible) — currently `TrainingSession` uses millisecond timestamps; migrate to proper UUIDs (`uuid` package or `DateTime.now().millisecondsSinceEpoch.toString()` as a stopgap).
- Dates stored as `DateTime` (UTC) → translates cleanly to ISO strings or timestamps in any DB.
- `TrainingType.iconCodePoint` stored as `int?` (Material Icon code point) — DB-friendly and deterministic.
- Stores currently expose synchronous CRUD wrapped in `ChangeNotifier`. When a DB is introduced, the interface will become `Future`-based and the store will likely become a view-model backed by a repository. Keep synchronous for the MVP, but **do** make callers `await` store methods now so UI code doesn't need refactoring later:
  ```dart
  Future<void> add(FocusPoint entity) async { _items.add(entity); notifyListeners(); }
  ```
- Abstracting stores behind an interface (`Store<T>` or repository pattern) at the outset is recommended but optional. If skipped, the DB migration will touch only the store internals, not the UI.

---

## 9. Implementation Order (Suggested)

| Step | Description | Depends on |
|---|---|---|
| 1 | Create `TrainingType` model + store + default seed data | — |
| 2 | Create `FocusPoint` model + store + seed data | — |
| 3 | Update `TrainingSession` model: replace `sportType` with `trainingType`, change `focusPoint` type to `FocusPoint?` | 1, 2 |
| 4 | Update `mock_sessions.dart` to use new model references | 3 |
| 5 | Rewrite `ProfilePage` with TrainingTypes and FocusPoints management | 1, 2 |
| 6 | Add Profile as a third tab in `HomeScreen` navigation | 5 |
| 7 | Create `ManageTrainingTypesPage` and `ManageFocusPointsPage` | 1, 2 |
| 8 | Update `AddSessionPage` to use `TrainingType` picker and `FocusPoint` picker, with inline creation | 1, 2, 6 |
| 9 | Create `TrainingStats` model and `StatsPage` UI | 3, 4 |
| 10 | Polish: empty states, validation, UX flows, cascade on delete | all |

---

## 10. Open Questions / Decisions to Make

- Should `FocusPoint` support multiple simultaneous active goals, or only one active at a time? (Recommend: multiple allowed, UI shows all unexpired.)
- Icon picker for `TrainingType`: predefined set vs free pick from all Material icons? (Recommend: a curated shortlist for simplicity.)
- Date range for `FocusPoint`: fixed calendar dates or a duration e.g. "4 weeks" that auto-calculates end date? (Recommend: start date + duration in weeks → auto-computed end date, editable.)
- Should deleting a `TrainingType` or `FocusPoint` cascade to existing sessions (set to null) or block deletion? (Recommend: set to null / warn user.)
- Should `TrainingStats` be a computed singleton (rebuilt on `SessionStore` notification) or recreated per widget build? (Recommend: lightweight helper class instantiated by `StatsPage`, not a store.)
- How to handle `TrainingType` or `FocusPoint` name uniqueness? (Recommend: case-insensitive uniqueness check in store `add`/`update`.)
