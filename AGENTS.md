# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Project Overview

Toot Fruit is a Flutter app that combines fruit imagery with curated fart sounds. Users swipe between different fruit characters (17 total), each with unique audio and visual themes. All fruits are freely available.

**IMPORTANT:** Read `.rules/flutter.md` for Flutter-specific guidelines.

## Developer Preferences & Code Quality Standards

### Code Quality Philosophy
This codebase follows **professional software engineering principles**:

- **SOLID Principles** - All code follows SOLID design patterns
- **No Code Smells** - Code smells are identified and eliminated immediately
- **Clean Architecture** - Clear separation of concerns (UI -> Business Logic -> Data)
- **Type Safety** - Explicit types, no dynamic unless necessary
- **Testability** - All business logic is easily testable

### Coding Standards

**DO:**
- Use dependency injection (constructor injection preferred)
- Write single-responsibility classes
- Use interfaces/abstract classes for dependencies
- Use constants for magic strings/numbers (see `/lib/constants/`)
- Add proper null safety checks
- Write clear, descriptive variable/method names
- Format code with `dart format` before committing
- Run `flutter analyze` and fix all issues

**DON'T:**
- Create god objects or classes with multiple responsibilities
- Use magic strings or hardcoded values
- Force-unwrap nullables without proper checks
- Add code smells (duplicate code, long methods, etc.)
- Skip writing tests for business logic
- Use `dynamic` type unless absolutely necessary

### MCP Servers Available

This project has the following MCP servers installed:

**Dart MCP** - Flutter development tools
- Hot reload/restart apps
- Run tests with `flutter test`
- Format code, fix issues
- Widget tree inspection
- Package management

**Playwright MCP** - Browser automation
- Screenshot capture for testing
- E2E testing capabilities
- Form testing and validation

## Development Commands

### Running the App
```bash
flutter run
flutter run -d <device_id>
flutter devices
```

### Building
```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios
```

### Code Generation
When modifying models with `@JsonSerializable()` annotations (User), regenerate the `*.g.dart` files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run all unit tests (67 tests)
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=integration_test/screen_visibility_integration_test.dart

# Generate mocks (after modifying interfaces)
dart run build_runner build --delete-conflicting-outputs
```

**Test Coverage**: 100% of business logic (repositories and services)

### Dependency Management
```bash
flutter pub get
flutter pub upgrade
flutter analyze
```

## Architecture

### Overview

```
┌─────────────────────────────────────────┐
│      Presentation Layer (UI)            │
│   Screens, Widgets                      │
└──────────────┬──────────────────────────┘
               │ depends on
               ▼
┌─────────────────────────────────────────┐
│      Business Logic Layer               │
│   Services (TootService, InitService)   │
│      depends on ▼ interfaces            │
└──────────────┬──────────────────────────┘
               │ implemented by
               ▼
┌─────────────────────────────────────────┐
│      Data Access Layer                  │
│   Repositories (User, Toot, Storage)    │
└──────────────┬──────────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────────┐
│      Infrastructure Layer               │
│   Storage, Audio                        │
└─────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── constants/           # All constants (no magic strings!)
│   └── storage_keys.dart        # Storage key constants
├── interfaces/          # Abstractions (DIP)
│   ├── i_audio_player.dart
│   ├── i_storage_repository.dart
│   ├── i_user_repository.dart
│   └── i_toot_repository.dart
├── repositories/        # Data access layer (SRP)
│   ├── storage_repository.dart  # File-based storage
│   ├── user_repository.dart     # User data persistence
│   └── toot_repository.dart     # Toot data access
├── services/            # Business logic layer
│   ├── toot_service.dart              # Toot selection, navigation, audio
│   ├── init_service.dart              # App initialization
│   ├── audio_service.dart             # Implements IAudioPlayer
│   ├── navigation_service.dart        # Navigation
│   ├── image_precache_service.dart    # Image preloading
│   ├── fruit_query_param.dart         # Web URL fruit param sync
│   ├── toot_transition.dart           # Fruit transition animations
│   └── toot_screen_route.dart         # Route builder for TootScreen
├── core/
│   └── dependency_injection.dart  # DI Container (singleton)
├── screens/             # UI layer
│   ├── launch_screen.dart       # Splash/loading, runs InitService
│   ├── toot_screen.dart         # Main screen, swipe between fruits
│   └── toot_fairy_screen.dart   # Fairy screen with secret easter egg
├── widgets/             # Reusable UI components
│   ├── fruit_asset.dart         # SVG fruit rendering
│   ├── cloud.dart               # Cloud animation
│   ├── rotating_fruit.dart      # Rotating fruit ring
│   ├── toot_fairy.dart          # Fairy widget with secret timer
│   └── screen_title.dart        # App bar title styling
├── models/              # Data models
│   ├── toot.dart                # Fruit character (17 total)
│   ├── user.dart                # User preferences (currentFruit)
│   └── user.g.dart              # Generated JSON serialization
├── app.dart             # MaterialApp with SwitchAudioObserver
├── main.dart            # Entry point, DI initialization
├── routes.dart          # Route definitions
└── env.dart             # App constants
```

### Dependency Injection

The app uses a singleton DI container:
```dart
final di = DI();

// Access services
final tootService = di.tootService;
final audioPlayer = di.audioPlayer;
final userRepo = di.userRepository;
```

The DI container fields are `late` (not `late final`) to support test `reset()`.

### Repository Pattern (Data Access)

**UserRepository** (`IUserRepository`)
- `loadUser()` - Load user from storage, validates currentFruit against known fruits
- `saveUser(User)` - Persist user
- `updateCurrentFruit(String)` - Update current fruit

**TootRepository** (`ITootRepository`)
- `getAllToots()` - Get all 17 toots
- `getTootByFruit(String)` - Find toot by name (falls back to first)

**StorageRepository** (`IStorageRepository`)
- `get<T>(String key)` - Get value
- `set(String key, dynamic value)` - Set value
- `remove(String key)` - Remove value
- `exists(String key)` - Check existence

### Service Layer (Business Logic)

**TootService**
- Toot selection and navigation (increment/decrement through all fruits)
- Audio loading via IAudioPlayer
- Query param reading/writing for web deep links
- `ensureCurrentAudioPrepared()` for retry on failed audio loads
- `shuffle()` for random fruit selection

**InitService**
- App initialization sequence
- Loads user, initializes audio, precaches images, initializes TootService

**AudioService** (`IAudioPlayer`)
- Uses **flutter_soloud** for high-performance audio playback
- All audio files preloaded on app startup for instant playback
- Must call `init()` before use (done in InitService)

### Navigation
- Routes defined in `lib/routes.dart`: `/launch`, `/toot`, `/toot_fairy`
- NavigationService provides access to navigator key
- SwitchAudioObserver monitors route changes to reset audio
- Web route names are normalized via `normalizeRouteName(...)` so query/hash forms
  like `/#/toot?fruit=banana` resolve to canonical routes (e.g. `/toot`)
- `MaterialApp` uses `onGenerateRoute`/`onUnknownRoute` for resilient route
  resolution and safe fallback to launch
- Initial app bootstrap navigation (LaunchScreen -> TootScreen) uses a
  fade-only transition route from `buildInitialTootScreenRoute()`

## Screens Flow

1. **LaunchScreen** (`/launch`) - Initial splash/loading screen, runs InitService
2. **TootScreen** (`/toot`) - Main screen, displays current fruit with swipe gestures, plays audio on tap
3. **TootFairyScreen** (`/toot_fairy`) - Fairy character with animations; secret: hold fairy 3 seconds to navigate back to TootScreen

## Key Models

### Toot (lib/models/toot.dart)
Represents a fruit character with associated sound. Contains static list of all toots (17 total). Properties include fruit name, title, emoji, color, darkText flag, and audio file extension.

### User (lib/models/user.dart)
Serializable model tracking:
- `currentFruit` - currently selected fruit (defaults to 'peach')

Uses json_serializable for JSON conversion.

## Android Build Configuration

- **Application ID**: com.gnarhard.tootfruit
- **Min SDK**: 33
- **Release signing**: Configured via `key.properties` file (not in repo)
- **MultiDex**: Enabled

Version code/name pulled from pubspec.yaml via flutter.gradle.

## Assets Structure

```
assets/
  audio/
    <fruit_name>.m4a or .mp3
  images/
    (general images)
    fruit/
      (fruit-specific SVG images)
```

## Common Patterns

### Adding a New Fruit
1. Add audio file to `assets/audio/`
2. Add Toot entry to `toots` list in `lib/models/toot.dart`
3. Add fruit SVG to `assets/images/fruit/` (if applicable)
4. Update `pubspec.yaml` assets section if needed

### Service Access Pattern
```dart
final di = DI();
final tootService = di.tootService;
```

### Audio System (flutter_soloud)

**Audio Pooling Architecture:**
- All 18 audio files (17 toots + 1 toot fairy intro) are preloaded on app startup
- Uses `flutter_soloud` for zero-latency playback from memory pools
- AudioService must be initialized via `audioService.init()` before use
- Init is called automatically in InitService

**Playback Pattern:**
1. `AudioService.init()` - Preloads all audio files into memory (called on app startup)
2. `setAudio(path)` - Sets current audio from preloaded pool (instant, no I/O)
3. `play()` - Plays from pooled source (instant playback)
4. `stop()` - Stops current playback

### Testing Pattern

```dart
test('increment toot navigates to next', () async {
  final mockTootRepo = MockITootRepository();
  final mockUserRepo = MockIUserRepository();
  final mockAudio = MockIAudioPlayer();

  when(mockTootRepo.getAllToots()).thenReturn(testToots);

  final service = TootService(
    tootRepository: mockTootRepo,
    userRepository: mockUserRepo,
    audioPlayer: mockAudio,
    readFruitQueryParam: () => null,
    writeFruitQueryParam: (_) {},
  );

  await service.increment();

  verify(mockUserRepo.updateCurrentFruit(testToots[1].fruit)).called(1);
  expect(service.current, equals(testToots[1]));
});
```

## Important Notes

### Critical Rules
- **ALWAYS** run `flutter analyze` before committing - zero errors/warnings required
- **ALWAYS** use constants instead of magic strings (see `/lib/constants/`)
- **NEVER** create code smells (duplicate code, long methods, god objects)
- **NEVER** skip null safety checks or use force unwrap without validation
- Generated files (`*.g.dart`) should not be manually edited

### App Behavior
- The app locks orientation to portrait mode only (set in main.dart)
- All fruits are freely available to all users
- Launch screen background color resolves from the selected fruit query param
  (if present/valid), otherwise defaults to peach
- Startup fruit selection honors `fruit` query params for any valid fruit name;
  unknown values fall back to persisted/current fruit
- Web URL syncing writes fruit query params in the hash route when a fragment
  route is used (`#/toot?fruit=...`) and removes stale root `?fruit=...`

### File Organization
- Constants go in `/lib/constants/`
- Interfaces go in `/lib/interfaces/`
- Repositories go in `/lib/repositories/`
- Business logic stays in `/lib/services/`

## Quick Reference

### When Adding Features

1. **Check if interface exists** - Use existing interfaces
2. **Create repository if needed** - Data access logic goes here
3. **Create service** - Business logic with dependency injection
4. **Write tests** - Mock dependencies, test in isolation
5. **Update DI container** - Wire up dependencies
6. **Run checks** - `flutter analyze` and format code

### When Fixing Bugs

1. **Write a failing test** - Reproduce the bug
2. **Fix the bug** - Minimal changes
3. **Verify test passes** - Ensure fix works
4. **Run full test suite** - No regressions
5. **Check code quality** - No new code smells

### Getting Help

- **Flutter rules**: See `.rules/flutter.md`

## Testing Requirements

- Always create or update automated tests for every code change.
- For bug fixes, add a regression test that fails before the fix and passes after the fix.
- Do not consider a task complete until relevant tests pass locally.

## UI Transition Requirements

- Render every fruit inside the same fixed square constraints so visual fruit sizes stay consistent across fruits.
- On fruit/page changes, linearly interpolate both page colors and fruit visuals (no ease-in/ease-out curves for these transitions).
