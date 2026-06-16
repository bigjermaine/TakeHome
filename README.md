# TakeHome iOS Assignment

A SwiftUI + UIKit sample shop app built with **Clean Architecture**, **MVVM**, route-based navigation, **SwiftData** offline caching, **Keychain** session storage, and **Nuke** image loading.

## Setup

1. Open `TakeHome.xcodeproj` in Xcode 16+.
2. Wait for Swift Package Manager to resolve **Nuke** (`https://github.com/kean/Nuke`).
3. Select an iOS Simulator (iPhone 15 or later, iOS 17+).
4. Run the `TakeHome` scheme.
5. Run unit tests: **Product → Test** (`⌘U`) or `xcodebuild test -scheme TakeHome -destination 'platform=iOS Simulator,name=iPhone 16'`.

## Test Credentials

| Field | Value |
|-------|-------|
| Username | `demo` |
| Password | `password123` |

After the first successful login, biometric sign-in is available if Face ID / Touch ID is enabled on the simulator or device.

## Architecture

```
Presentation (MVVM + Route enums)
    Views / ViewModels / AppRouter
        ↓
Domain
    Entities, Use Cases, Repository Protocols, Pagination, ProductFiltering
        ↓
Data
    Repository implementations, DTO mappers, SwiftData, URLSession API client
        ↓
Platform
    Keychain, NetworkMonitor, LocalAuthentication, Nuke ImagePipeline
```

### Layer responsibilities

| Layer | Role |
|-------|------|
| **Presentation** | SwiftUI screens, UIKit login, ViewModels, `AppRouter` navigation |
| **Domain** | Business rules (`ProductFiltering`), use cases, repository protocols |
| **Data** | DummyJSON API, SwiftData persistence, repository implementations |
| **Platform** | Keychain, biometrics, network reachability, Nuke pipeline |

Dependency direction is inward only: Presentation → Domain ← Data/Platform.

### Navigation

- `AppRoute` switches between login and main app.
- `ProductRoute` drives `NavigationStack` push flows (detail, editor) on both Products and Favorites tabs.
- `TabRoute` selects Products / Favorites / Settings tabs.
- `AppRouter` owns separate paths for products and favorites so detail navigation stays in-tab.

### Image loading (Nuke)

Remote product thumbnails and galleries use **Nuke** via `ProductImageView` (`NukeUI.LazyImage`) with a disk-backed `ImagePipeline`. Prefetching runs from `ProductDetailViewModel` when detail images load.

**Why Nuke:** paginated product lists need memory/disk caching, request coalescing, and cancellation during scrolling—more than `AsyncImage` provides without custom infrastructure.

### Offline behavior

- Product JSON is cached in **SwiftData** and shown immediately on launch.
- `NetworkMonitor` (`NWPathMonitor`) surfaces an offline banner on the product list.
- Images already fetched remain available from Nuke's disk cache.
- Local add/edit/delete changes persist until **Reset** restores API data.

### Pagination

Reusable domain types (`PageRequest`, `PaginatedResult`) coordinate skip/limit paging. `ProductListViewModel` uses them for refresh and infinite scroll.

## Features

- Username/password login with validation, loading, and error states
- **UIKit login screen** with `UITextField`, `UIButton`, `UIActivityIndicatorView`, and animated logo
- Biometric login via LocalAuthentication (Face ID / Touch ID icon adapts to device)
- Keychain-backed session persistence
- Paginated product list from DummyJSON
- Search (debounced), category filter, and sorting
- Product detail with Nuke image gallery + prefetch
- Favorites with in-tab detail navigation, swipe-to-remove, undo banner, error state
- Local product CRUD + reset from API
- Settings: theme (system/light/dark), English/Hebrew, logout
- Runtime locale switching via `AppLocalization` + `Localizable.xcstrings`

## Testing

`TakeHomeTests` includes XCTest coverage with mock repositories:

- Auth use cases (login, session validation, logout, biometrics)
- `ProductFiltering` (search, category, sort, deleted items)
- `Pagination` (page requests, has-more logic)

Mocks live in `TakeHomeTests/Mocks/TestMocks.swift`.

## Assumptions

- DummyJSON is the product catalog source; authentication is mocked locally because the API has no auth endpoint.
- Demo credentials are hard-coded in `AuthRepository` for the assignment scope.
- English is the default locale; Hebrew covers primary UI strings via string catalog.
- Local product edits (negative IDs) merge with API data on the first page only.

## Trade-offs & Limitations

- Authentication is mocked locally (DummyJSON has no auth API).
- Pagination skip uses displayed list count, which includes local-only products on page one.
- Hebrew localization covers primary UI strings; API product titles/descriptions remain English.
- Images for products never opened before may be unavailable offline.
- No Lottie animation on login (native UIKit animation used instead to avoid extra dependency).

## AI Usage Report

| Item | Details |
|------|---------|
| Tool | Cursor (Claude) |
| Assisted with | Project scaffolding, Clean Architecture layering, Nuke integration, localization, navigation, test target setup |
| Manual review | Repository merge logic, pagination edge cases, auth/session behavior, locale switching, build and test verification |

### Prompts used

1. **Architecture:** "Structure the take-home app with Clean Architecture + MVVM, route-based navigation, and separate Domain/Data/Platform layers."
2. **Navigation:** "Design `AppRouter` with `AppRoute`, `ProductRoute`, and tab routes; keep favorites detail navigation in the Favorites tab."
3. **Images:** "Justify and implement Nuke for paginated product image loading with disk cache and prefetch on detail."
4. **Standards audit:** "Make the codebase meet the assignment PDF standards—tests, offline indicator, Keychain in Platform, UIKit login, README."

### Verification

- Xcode build of `TakeHome` target
- `TakeHomeTests` unit tests (`AuthUseCaseTests`, `ProductFilteringTests`, `PaginationTests`)
- Manual flows: login, biometrics, products (search/filter/pagination), favorites (undo), settings (theme/language/logout), offline cache

## Project Structure

```
TakeHome/
├── App/                 # DIContainer, AppPreferencesStore, AppLocalization
├── Domain/              # Entities, protocols, use cases, Pagination, ProductFiltering
├── Data/                # API, SwiftData, repositories
├── Platform/            # Keychain, NetworkMonitor, biometrics, Nuke
├── Presentation/        # MVVM views, router, UIKit login
└── Resources/           # Localizable.xcstrings

TakeHomeTests/
├── Mocks/               # Mock repositories for unit tests
├── AuthUseCaseTests.swift
├── ProductFilteringTests.swift
└── PaginationTests.swift
```
