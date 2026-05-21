# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on device/emulator
flutter run

# Build APK
flutter build apk

# Run tests
flutter test

# Run single test file
flutter test test/some_test.dart

# Analyze code
flutter analyze

# Get dependencies
flutter pub get
```

## Architecture

Flutter app using **GetX** for state management, dependency injection, and routing. No backend — all persistence via `shared_preferences`.

### Route flow

`Splash → Menu → Game` (defined in `lib/routes/app_pages.dart`)

Each route has a matching **Binding** (`lib/bindings/`) that injects its controller via `Get.put`. `GameBinding` uses `Get.delete(force: true)` before `Get.put` to force a fresh controller on every game start.

### GetX pattern

- **Controllers** (`lib/controllers/`) — all state as `Rx` observables (`.obs`). Views rebuild via `Obx(()=>...)`.
- **Views** (`lib/views/`) — extend `GetView<ControllerType>`, access controller via `controller`.
- **Bindings** (`lib/bindings/`) — wired in `AppPages.routes`, called automatically by GetX before the page is shown.

### Game engine (`GameController`)

Core loop driven by a single `AnimationController` (ticker via `GetSingleTickerProviderStateMixin`).

- Notes are a flat list of `Note(orderNumber, line)` where `line` ∈ `{0,1,2,3}` (columns) or `-1` for invisible padding notes. The last 4 notes are always padding (`_paddingNotes = 4`).
- `currentNoteIndex` points to the note currently animating. Each animation tick moves tiles down one tile-height; on completion the listener checks if the note was tapped.
- Tap validation: a note can only be tapped if all previous notes are already in `NoteState.tapped` (enforces left-to-right ordering within a row).
- **Infinite mode**: on song completion the song's note list is extended in-place (`_appendMoreNotes`) and animation speed increases by 8% per loop (`_speedIncreasePerLoop = 0.08`), clamped at `_minDurationMs = 80ms`.

### Adding a new song

1. Add a notes factory function in `lib/models/song_provider.dart` (or a new file).
2. Add a `SongModel` entry to `availableSongs` in `lib/models/song_model.dart` referencing that factory.
3. Songs with `isLocked: true` show a lock icon and require a previous song to be completed (checked via `RecordService.isCompleted`).

### Persistence (`RecordService`)

`shared_preferences` keys:
- `record_<songId>` — high score (int) for normal mode
- `record_<songId>_infinite` — high score for infinite mode
- `completed_<songId>` — bool flag set when a song is finished cleanly

### Rendering

`Line` (an `AnimatedWidget`) receives a 5-note sliding window from `GamePage` and translates each tile vertically using the animation value. `LineDivider` is a purely cosmetic separator between columns.

### Assets

Audio files (`a.wav`, `c.wav`, `e.wav`, `f.wav`) map 1-to-1 to the 4 tile columns (line index 0–3). Background image: `assets/background.jpg`.
