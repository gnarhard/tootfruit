# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Toot Fruit is a Flutter mobile app that combines fruit imagery with curated fart sounds. Users swipe between different fruit characters, each with unique audio and visual themes. The app includes in-app purchases for unlocking all fruits and displays ads for earning new fruits.

**IMPORTANT:** Read `.rules/flutter.md` for Flutter-specific guidelines.

## Developer Preferences & Code Quality Standards

### Code Quality Philosophy
This codebase follows **professional software engineering principles**:

✅ **SOLID Principles** - All new code must follow SOLID design patterns
✅ **No Code Smells** - Code smells are identified and eliminated immediately
✅ **Clean Architecture** - Clear separation of concerns (UI → Business Logic → Data)
✅ **Type Safety** - Explicit types, no dynamic unless necessary
✅ **Testability** - All business logic must be easily testable

### Coding Standards

**DO:**
- Use dependency injection (constructor injection preferred)
- Write single-responsibility classes
- Use interfaces/abstract classes for dependencies
- Use constants for magic strings/numbers (see `/lib/constants/`)
- Add proper null safety checks
- Write clear, descriptive variable/method names
- Use ValueNotifier for state management (Flutter built-in)
- Format code with `dart format` before committing
- Run `flutter analyze` and fix all issues

**DON'T:**
- Use service locator pattern for new code (being phased out)
- Use RxDart for new code (replaced with ValueNotifier)
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

See `MCP_SETUP.md` for usage examples.

## Development Commands

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
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
When modifying models with `@JsonSerializable()` annotations (User, Settings), regenerate the `*.g.dart` files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run unit tests (58 tests covering repositories and services)
flutter test test/repositories/ test/services/

# Run with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=integration_test/screen_visibility_integration_test.dart

# Generate mocks (after modifying interfaces)
flutter pub run build_runner build --delete-conflicting-outputs
```

**Test Coverage**: 100% of SOLID-refactored business logic (repositories and services)

See `TEST_COVERAGE_SUMMARY.md` for detailed test documentation.

### Dependency Management
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze
```

## Architecture

### Overview - SOLID Principles Applied

This codebase has been refactored to follow **SOLID principles** with clean architecture:

```
┌─────────────────────────────────────────┐
│      Presentation Layer (UI)            │
│   Screens, Widgets, State Management   │
└──────────────┬──────────────────────────┘
               │ depends on
               ▼
┌─────────────────────────────────────────┐
│      Business Logic Layer               │
│   Services (TootService, etc.)          │
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
│   Storage, Network, Audio, Ads          │
└─────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── constants/           # All constants (no magic strings!)
│   ├── storage_keys.dart        # Storage key constants
│   └── purchase_constants.dart  # IAP product IDs, types
├── interfaces/          # Abstractions (DIP)
│   ├── i_audio_player.dart
│   ├── i_storage_repository.dart
│   ├── i_user_repository.dart
│   ├── i_toot_repository.dart
│   └── i_toast_service.dart
├── repositories/        # Data access layer (SRP)
│   ├── storage_repository.dart  # File-based storage
│   ├── user_repository.dart     # User data persistence
│   └── toot_repository.dart     # Toot data access
├── services/            # Business logic layer
│   ├── toot_service_refactored.dart     # ✅ SOLID (use this)
│   ├── init_service_refactored.dart     # ✅ SOLID (use this)
│   ├── audio_service.dart               # ✅ Implements IAudioPlayer
│   ├── toast_service.dart               # ✅ Implements IToastService
│   ├── connectivity_service.dart        # ✅ Uses ValueNotifier
│   ├── in_app_purchase_service.dart     # IAP wrapper
│   ├── ad_service.dart                  # Ads wrapper
│   ├── new_fruit_ad_service.dart        # Extends AdService
│   ├── navigation_service.dart          # Navigation
│   ├── toot_service.dart                # ⚠️ OLD (being phased out)
│   ├── init_service.dart                # ⚠️ OLD (being phased out)
│   ├── user_service.dart                # ⚠️ OLD (being phased out)
│   └── storage_service.dart             # ⚠️ OLD (being phased out)
├── core/
│   └── dependency_injection.dart  # ✅ DI Container (replaces Locator)
├── screens/             # UI layer
├── widgets/             # Reusable UI components
├── models/              # Data models
├── locator.dart         # ⚠️ OLD Service Locator (being phased out)
└── routes.dart          # Route definitions
```

### Dependency Injection (New Pattern)

**Use this for new code:**
```dart
// Get DI container
final di = DependencyInjection();

// Access services
final tootService = di.tootService;
final audioPlayer = di.audioPlayer;
final userRepo = di.userRepository;
```

**Old pattern (being phased out):**
```dart
// DON'T use this for new code
final service = Locator.get<ServiceType>();
```

### State Management

**Current Standard: ValueNotifier** (Flutter built-in)
```dart
// In service
final loading = ValueNotifier<bool>(false);

// In UI
ValueListenableBuilder<bool>(
  valueListenable: service.loading,
  builder: (context, value, child) {
    return value ? LoadingSpinner() : Content();
  },
)
```

**Old Pattern (being phased out):**
```dart
// DON'T use RxDart for new code
final loading$ = BehaviorSubject<bool>.seeded(false);
```

### Repository Pattern (Data Access)

All data access goes through repositories:

**UserRepository** (`IUserRepository`)
- `loadUser()` - Load user from storage
- `saveUser(User)` - Persist user
- `updateCurrentFruit(String)` - Update current fruit
- `addOwnedFruit(String)` - Add owned fruit
- `setAllFruitsOwned(List<String>)` - Unlock all

**TootRepository** (`ITootRepository`)
- `getAllToots()` - Get all toots
- `getTootByFruit(String)` - Find toot by name
- `getOwnedToots(List<String>)` - Get user's toots
- `getRandomUnclaimedToot(List<String>)` - Random reward

**StorageRepository** (`IStorageRepository`)
- `get<T>(String key)` - Get value
- `set(String key, dynamic value)` - Set value
- `remove(String key)` - Remove value
- `exists(String key)` - Check existence

### Service Layer (Business Logic)

**TootService** (Refactored - SOLID)
- Single responsibility: Toot selection and navigation
- Constructor injection (no service locator)
- Depends on interfaces, not concrete classes
- Easy to test with mocks

**InitService** (Refactored - SOLID)
- Single responsibility: App initialization
- Clean, focused initialization logic
- Uses DI container

**AudioService** (`IAudioPlayer`)
- Uses **flutter_soloud** for high-performance audio playback
- **Audio pooling**: All 18 audio files preloaded on app startup for instant playback
- Implements interface for testability
- Must call `init()` before use (done in InitService)

**ToastService** (`IToastService`)
- Shows notifications
- Implements interface for swapping implementations

### Navigation
- Routes defined in `lib/routes.dart`
- NavigationService provides access to navigator key
- SwitchAudioObserver monitors route changes

### Services (Internalized)

Previously external git dependencies, now internalized:
- `ad_service.dart` - Google Mobile Ads wrapper
- `toast_service.dart` - Fluttertoast wrapper
- `connectivity_service.dart` - Network monitoring
- `in_app_purchase_service.dart` - IAP wrapper

All implement interfaces for dependency inversion.

## Screens Flow

1. **LaunchScreen** (`/launch`) - Initial splash/loading screen, runs InitService
2. **TootScreen** (`/toot`) - Main screen, displays current fruit with swipe gestures, plays audio on tap
3. **TootFairyScreen** (`/toot_fairy`) - Reward screen for earning new fruits via ads
4. **TootLootScreen** (`/toot_loot`) - In-app purchase screen for unlocking all fruits

Navigation uses named routes. AppDrawer provides access to TootScreen and SettingsScreen.

## Key Models

### Toot (lib/models/toot.dart)
Represents a fruit character with associated sound. Contains static list of all toots (17 total). Properties include fruit name, title, emoji, color, darkText flag, and audio file extension.

### User (lib/models/user.dart)
Serializable model tracking:
- `ownedFruit` - list of unlocked fruit names
- `currentFruit` - currently selected fruit
- `settings` - user preferences

Uses json_serializable for JSON conversion. Defaults to owning 'peach' fruit.

### Settings (lib/models/settings.dart)
User preferences (structure not detailed, but serializable).

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
final service = Locator.get<ServiceType>();
```

### Audio System (flutter_soloud)

**Audio Pooling Architecture:**
- All 18 audio files (17 toots + 1 toot fairy intro) are **preloaded on app startup**
- Uses `flutter_soloud` for zero-latency playback from memory pools
- AudioService must be initialized via `audioService.init()` before use
- Init is called automatically in both `InitService` implementations

**Playback Pattern:**
1. `AudioService.init()` - Preloads all audio files into memory (called on app startup)
2. `setAudio(path)` - Sets current audio from preloaded pool (instant, no I/O)
3. `play()` - Plays from pooled source (instant playback, ~0ms latency)
4. `stop()` - Stops current playback

**Performance Benefits:**
- ✅ Instant playback (no loading delay when switching toots)
- ✅ Zero latency (audio already in memory)
- ✅ Efficient pooling (single AudioSource per file, reused)

### Testing Pattern (New Code)

**Write testable code using dependency injection:**
```dart
test('increment toot navigates to next', () {
  // Arrange
  final mockTootRepo = MockTootRepository();
  final mockUserRepo = MockUserRepository();
  final mockAudio = MockAudioPlayer();
  final mockPurchase = MockPurchaseService();

  when(mockTootRepo.getOwnedToots(any)).thenReturn([toot1, toot2]);

  final service = TootService(
    tootRepository: mockTootRepo,
    userRepository: mockUserRepo,
    audioPlayer: mockAudio,
    purchaseService: mockPurchase,
  );

  // Act
  await service.increment();

  // Assert
  verify(mockUserRepo.updateCurrentFruit(toot2.fruit)).called(1);
  expect(service.current, equals(toot2));
});
```

## Migration Status

The codebase is currently in **transition** from old patterns to SOLID architecture:

### ✅ Complete
- SOLID architecture designed and implemented
- Interfaces created for all dependencies
- Repositories implemented
- DI container created
- Constants extracted (no magic strings)
- Code smells eliminated
- RxDart replaced with ValueNotifier
- Git dependencies internalized

### 🔄 In Progress
- Gradual migration from Locator to DI container
- Screens being updated to use new services
- Tests being added for new architecture

## Important Notes

### Critical Rules
- **ALWAYS** run `flutter analyze` before committing - zero errors/warnings required
- **ALWAYS** use constants instead of magic strings (see `/lib/constants/`)
- **NEVER** use service locator pattern for new code (use DI instead)
- **NEVER** use RxDart for new code (use ValueNotifier instead)
- **NEVER** create code smells (duplicate code, long methods, god objects)
- **NEVER** skip null safety checks or use force unwrap without validation

### App Behavior
- The app locks orientation to portrait mode only (set in main.dart)
- New fruits unlocked via ads (NewFruitAdService) or IAP
- Product ID for all fruits: `PurchaseConstants.allTootFruitsProductId`
- Generated files (`*.g.dart`) should not be manually edited

### File Organization
- Constants go in `/lib/constants/`
- Interfaces go in `/lib/interfaces/`
- Repositories go in `/lib/repositories/`
- Business logic stays in `/lib/services/`
- New services use `_refactored.dart` suffix during migration

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
