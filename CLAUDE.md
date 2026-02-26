# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Project Overview

Toot Fruit is a Flutter app that combines fruit imagery with curated fart sounds.
Users can swipe/tap/keyboard-navigate between 17 fruit characters, each with its own
visual style and sound. The app also includes a separate Toot Fairy mini-game screen.
All fruits are freely available.

Current app baseline:
- Version: `2.1.0+10`
- Dart SDK constraint: `^3.10.7`
- Primary routes: `/launch`, `/toot`, `/toot_fairy`

**IMPORTANT:** Read `.rules/flutter.md` for Flutter-specific guidelines.

## Developer Preferences & Code Quality Standards

### Code Quality Philosophy
This codebase follows professional software engineering principles:

- SOLID principles
- No code smells
- Clean architecture (UI -> business logic -> data)
- Type safety
- Testability

### Coding Standards

DO:
- Use dependency injection (constructor injection preferred)
- Write single-responsibility classes
- Use interfaces/abstract classes for dependencies
- Use constants for magic strings/numbers (see `/lib/constants/`)
- Add proper null safety checks
- Write clear, descriptive variable/method names
- Format code with `dart format` before committing
- Run `flutter analyze` and fix all issues

DON'T:
- Create god objects or classes with multiple responsibilities
- Use magic strings or hardcoded values
- Force-unwrap nullables without proper checks
- Add code smells (duplicate code, long methods, etc.)
- Skip tests for business logic changes
- Use `dynamic` unless absolutely necessary

### MCP Servers Available

This project uses:

- Dart MCP
- Playwright MCP

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

# Web
flutter build web
```

### Code Generation
When modifying `@JsonSerializable()` models or Mockito annotations:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Unit + widget tests
flutter test

# Coverage
flutter test --coverage

# Integration tests (recommended)
flutter test integration_test

# Single integration test (legacy style)
flutter drive --target=integration_test/screen_visibility_integration_test.dart
```

Integration coverage currently includes:
- core screen visibility/flow
- web desktop left/right navigation
- web/desktop spacebar activation

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
│   Local storage, audio backend          │
└─────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── constants/
│   └── storage_keys.dart
├── interfaces/
│   ├── i_audio_player.dart
│   ├── i_storage_repository.dart
│   ├── i_user_repository.dart
│   └── i_toot_repository.dart
├── repositories/
│   ├── storage_repository.dart
│   ├── user_repository.dart
│   └── toot_repository.dart
├── services/
│   ├── audio_service.dart
│   ├── fruit_query_param.dart
│   ├── fruit_query_param_initial_url_stub.dart
│   ├── fruit_query_param_initial_url_web.dart
│   ├── fruit_query_param_update_stub.dart
│   ├── fruit_query_param_update_web.dart
│   ├── image_precache_service.dart
│   ├── init_service.dart
│   ├── navigation_service.dart
│   ├── toot_screen_route.dart
│   ├── toot_service.dart
│   └── toot_transition.dart
├── core/
│   └── dependency_injection.dart
├── screens/
│   ├── launch_screen.dart
│   ├── toot_screen.dart
│   └── toot_fairy_screen.dart
├── widgets/
│   ├── cloud.dart
│   ├── fruit_asset.dart
│   ├── rotating_fruit.dart
│   ├── screen_title.dart
│   └── toot_fairy.dart
├── models/
│   ├── toot.dart
│   ├── user.dart
│   └── user.g.dart
├── app.dart
├── main.dart
├── routes.dart
└── env.dart
```

### Dependency Injection

The app uses a singleton DI container:
```dart
final di = DI();

final tootService = di.tootService;
final audioPlayer = di.audioPlayer;
final userRepo = di.userRepository;
```

DI fields are `late` (not `late final`) to support test reset/overrides.

### Repository Pattern (Data Access)

UserRepository (`IUserRepository`)
- `loadUser()`
- `saveUser(User)`
- `updateCurrentFruit(String)`

TootRepository (`ITootRepository`)
- `getAllToots()`
- `getTootByFruit(String)`

StorageRepository (`IStorageRepository`)
- `get<T>(String key)`
- `set(String key, dynamic value)`
- `remove(String key)`
- `exists(String key)`
- `clear()`

## Service Layer (Business Logic)

TootService:
- selects current toot, increments/decrements across all fruits
- applies deep-link fruit selection at startup
- updates persistent user fruit
- writes canonical fruit URL on web
- prepares audio and retries via `ensureCurrentAudioPrepared()`

InitService:
- in debug mode, clears persisted storage file at startup
- initializes audio, user, and toot state
- navigates launch -> toot using a fade route

AudioService (`IAudioPlayer`):
- uses `flutter_soloud` + `audio_session`
- initializes backend once, then warmups toot sources in the background
- preloads all toot sounds plus `toot_fairy_intro.mp3`
- lazily loads additional assets on demand

ImagePrecacheService:
- preloads toot fairy raster assets and all fruit SVGs before leaving launch

## Navigation & URL Behavior

- Routes are defined in `lib/routes.dart`
- Route normalization handles canonical and hash/query forms
- Unknown routes fall back safely to launch
- Recognized fruit deep-link patterns include:
  - `/banana`
  - `/toot/banana`
  - `/#/banana`
  - `/#/toot/banana`
- Web URL syncing writes canonical hash-route fruit URLs:
  - `/#/toot/<fruit>`
- Stale root `?fruit=...` query params are removed when syncing.

## Screens Flow

1. LaunchScreen (`/launch`)
   - shows loading UI
   - precaches launch/fruit assets
   - runs InitService bootstrap
2. TootScreen (`/toot`)
   - main fruit experience
   - swipe left/right to change fruit
   - tap/long-press fruit to play toot audio + animation
   - desktop/web adds left/right nav buttons and keyboard arrows
   - web/desktop supports spacebar toot trigger
3. TootFairyScreen (`/toot_fairy`)
   - arcade mini-game with falling fruits, score, particles, game-over/share flow
   - start screen contains animated fairy scene
   - back button returns to toot screen
   - the `TootFairy` widget still contains a hidden 3-second hold easter egg

## Key Models

Toot (`lib/models/toot.dart`):
- 17 fruit entries
- fields: fruit, title, emoji, fileExtension, color, darkText, duration

User (`lib/models/user.dart`):
- tracks `currentFruit` (default: `peach`)
- serialized with `json_serializable`

## Android Build Configuration

- Application ID: `com.gnarhard.tootfruit`
- Min SDK: `33`
- Release signing: via `android/key.properties` when present
- If release signing is missing, release builds fall back to debug signing
- MultiDex enabled

Version code/name are pulled from `pubspec.yaml`.

## Assets Structure

```
assets/
  audio/
    <fruit_name>.mp3
    toot_fairy_intro.mp3
    toot_fairy.mp3
    fart_button.mp3
  images/
    fruit/
      <fruit>.svg
  licenses/
    asset license documentation
```

## Common Patterns

### Adding a New Fruit
1. Add audio file to `assets/audio/`
2. Add toot entry in `lib/models/toot.dart`
3. Add corresponding SVG in `assets/images/fruit/`
4. Ensure `pubspec.yaml` includes needed asset paths
5. Add/update tests for routing/navigation/audio expectations

### Service Access Pattern
```dart
final di = DI();
final tootService = di.tootService;
```

### Audio Lifecycle Pattern
1. `audioPlayer.init()`
2. `tootService.init()` (sets current toot + initial audio)
3. `audioPlayer.play()` on interaction
4. `tootService.ensureCurrentAudioPrepared()` when recovering from zero-duration load

## Important Notes

### Critical Rules
- ALWAYS run `flutter analyze` before committing
- ALWAYS avoid magic strings where constants should exist
- NEVER bypass null-safety checks without justification
- NEVER manually edit generated files (`*.g.dart`, `*.mocks.dart`)

### Current App Behavior
- App runtime is portrait-only (enforced in `main.dart`)
- Launch background color reflects requested fruit when deep-link fruit is valid
- Startup fruit selection supports query/path/fragment variants
- Unknown deep-link fruit values fall back to persisted/default fruit
- Fruit/page transitions are intentionally linear for both visuals and colors
- Fruits are rendered in fixed square constraints to keep visual size consistent

### File Organization
- constants -> `/lib/constants/`
- interfaces -> `/lib/interfaces/`
- repositories -> `/lib/repositories/`
- business logic -> `/lib/services/`

## Quick Reference

### When Adding Features
1. Check whether an interface already exists.
2. Implement/update repository if data access changes.
3. Implement/update service for business logic.
4. Add/adjust tests.
5. Wire dependencies in DI.
6. Run `dart format`, `flutter analyze`, and relevant tests.

### When Fixing Bugs
1. Add a failing test to reproduce.
2. Apply minimal fix.
3. Verify new test passes.
4. Run broader tests for regressions.
5. Confirm no new code smells.

### Getting Help
- Flutter rules: `.rules/flutter.md`

## Testing Requirements

- Always create or update automated tests for every code change.
- For bug fixes, add a regression test that fails before and passes after the fix.
- Do not consider a task complete until relevant tests pass locally.

## UI Transition Requirements

- Render every fruit inside the same fixed square constraints so visual fruit sizes stay consistent.
- On fruit/page changes, linearly interpolate both page colors and fruit visuals (no ease-in/ease-out curves for these transitions).
