# TakeHome — iOS Swift Take-Home Assignment

A small iOS shop app built for the **iOS Swift Take-Home Assignment**. The focus is clean architecture, scalability, maintainability, and modern Swift—not pixel-perfect UI.

| | |
|---|---|
| **API** | [DummyJSON Products](https://dummyjson.com/products) |
| **Min iOS** | 17.0 |
| **Xcode** | 16+ |
| **Estimated scope** | 8–12 hours (per assignment brief) |

---

## Quick Start

1. Open `TakeHome.xcodeproj` in Xcode 16+.
2. Wait for Swift Package Manager to resolve **Nuke** (`https://github.com/kean/Nuke`).
3. Select an iOS Simulator (iPhone 15+, iOS 17+).
4. Run the `TakeHome` scheme (`⌘R`).

### Run unit tests

```bash
xcodebuild test \
  -scheme TakeHome \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or in Xcode: **Product → Test** (`⌘U`).

---

## Test Credentials

| Field | Value |
|-------|-------|
| Username | `demo` |
| Password | `password123` |

After the first successful login, biometric sign-in is available if Face ID / Touch ID is enabled on the simulator or device.

---

## Feature Checklist (Assignment PDF)

### Authentication ✅

| Requirement | Implementation |
|-------------|----------------|
| Username/password login | `LoginViewController` (UIKit) + `LoginViewModel` |
| Face ID / Touch ID | `BiometricAuthenticator` via LocalAuthentication |
| Persistent session | Keychain via `KeychainService` + `AuthRepository` |
| Input validation, loading & error states | `LoginViewModel.ViewState`, inline error label |
| Lightweight animation | Native UIKit logo scale animation on login screen |

### Products ✅

| Requirement | Implementation |
|-------------|----------------|
| Fetch from DummyJSON | `ProductRemoteDataSource` + `APIClient` |
| Paginated list | `PageRequest` / `PaginatedResult`, infinite scroll in `ProductListViewModel` |
| Product details | `ProductDetailView` with Nuke image gallery + prefetch |
| Search, sort, filter | Debounced search, category picker, sort options, `ProductFiltering` |
| Offline caching | SwiftData (`ProductRecord`) + offline banner via `NetworkMonitor` |

### Favorites ✅

| Requirement | Implementation |
|-------------|----------------|
| Add/remove favorites | Heart toggle on list & detail, `ToggleFavoriteUseCase` |
| Persist locally | SwiftData `FavoriteRecord` |
| Undo remove | `UndoBanner` on Favorites tab with 5-second undo window |

### Settings ✅

| Requirement | Implementation |
|-------------|----------------|
| Dark / light mode | `AppTheme` + `AppPreferencesStore` |
| English / Hebrew | `AppLanguage` + `Localizable.xcstrings` |
| Logout | `LogoutUseCase` + `AppRouter.showLogin()` |

### CRUD (local) ✅

| Requirement | Implementation |
|-------------|----------------|
| **Add** products | `+` toolbar → `ProductEditorView` → `SaveProductUseCase` (negative local IDs) |
| **Edit** products | Edit toolbar on detail → `ProductEditorView` |
| **Delete** products | Trash toolbar on detail → confirmation alert → `DeleteProductUseCase` |
| **Reset** from API | Reset toolbar on product list → `ResetProductsUseCase` |

#### Local delete behavior

Deleting from the product detail screen removes the item from your **local catalog**:

| Product type | What happens |
|--------------|--------------|
| **Locally created** (`isLocalOnly`) | Permanently removed from SwiftData |
| **From DummyJSON** | Soft-deleted locally (`isDeleted = true`); hidden from list until **Reset** restores the API catalog |

Confirmation messages (English + Hebrew):

- Local product: *"This locally created product will be permanently removed from your device."*
- API product: *"This product will be hidden from your catalog until you reset local changes."*

The delete confirmation is presented from `MainTabView` (not inside navigation) so the alert reliably appears on all devices.

**Favorites** are separate from delete: heart toggle adds/removes favorites; swipe-to-remove on the Favorites tab includes undo.

---

## Required Tech Stack

| Category | Requirement | This project |
|----------|-------------|--------------|
| Language | Swift | Swift 5.9+ |
| UI | SwiftUI + UIKit | SwiftUI tabs/lists; UIKit login screen |
| Architecture | MVVM / MVI / TCA | **MVVM** + Clean Architecture |
| Async | async/await, Task | API calls, ViewModel tasks |
| DI | Constructor injection / container | `DIContainer` with lazy use cases |
| Networking | URLSession + Codable | `APIClient` |
| Local storage | SwiftData, UserDefaults, Keychain | SwiftData products/favorites; Keychain session; UserDefaults settings |
| Pagination | Manual cursor/limit | `PageRequest`, skip/limit paging |
| Images | AsyncImage / Nuke | **Nuke** + disk cache + prefetch |
| Testing | XCTest (XCUITest optional) | **38+ unit tests** in `TakeHomeTests` |

---

## Architecture

```
Presentation (MVVM + routes)
    Views / ViewModels / AppRouter
        ↓
Domain
    Entities, Use Cases, Repository Protocols, Pagination, ProductFiltering
        ↓
Data
    Repositories, DTO mappers, SwiftData, URLSession API client
        ↓
Platform
    Keychain, NetworkMonitor, LocalAuthentication, Nuke ImagePipeline
```

**Dependency rule:** Presentation → Domain ← Data / Platform (inward only).

### Layer responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | SwiftUI screens, UIKit login, ViewModels, `AppRouter` navigation |
| **Domain** | Business rules, use cases, repository protocols, pure utilities |
| **Data** | DummyJSON API, SwiftData persistence, repository implementations |
| **Platform** | Keychain, biometrics, network reachability, Nuke pipeline |

### Navigation

- `AppRoute` — login vs main app
- `ProductRoute` — detail and editor pushes (Products & Favorites tabs)
- `TabRoute` — Products / Favorites / Settings
- `AppRouter` — separate `NavigationPath` per tab; delete confirmation at tab root

### Offline-first

- Products cached in SwiftData and shown on launch
- `NetworkMonitor` offline banner on product list
- Nuke disk cache for previously loaded images
- Local CRUD persists until **Reset** restores API data

---

## Project Structure

```
TakeHome/
├── App/                    # DIContainer, AppPreferencesStore, AppLocalization
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   ├── Repositories/       # Protocols
│   ├── Pagination/
│   └── Utilities/          # ProductFiltering
├── Data/
│   ├── Remote/             # APIClient, ProductRemoteDataSource
│   ├── Local/              # SwiftData models & data sources
│   ├── Repositories/
│   └── Mappers/
├── Platform/               # Keychain, biometrics, NetworkMonitor, Nuke
├── Presentation/
│   ├── Auth/
│   ├── Products/           # Views + ViewModels per screen
│   ├── Favorites/
│   ├── Settings/
│   ├── Navigation/
│   ├── Root/
│   └── Components/
└── Resources/              # Localizable.xcstrings

TakeHomeTests/
├── Mocks/                  # One mock per file
├── AuthUseCaseTests.swift
├── FavoritesUseCaseTests.swift
├── ProductUseCaseTests.swift
├── ProductFilteringTests.swift
├── ProductEntityTests.swift
└── PaginationTests.swift
```

---

## Testing

Unit tests use **XCTest** with mock repositories in `TakeHomeTests/Mocks/`.

| Test file | Coverage |
|-----------|----------|
| `AuthUseCaseTests` | Login, logout, session, biometrics (success/unavailable/failed), `AuthError` |
| `FavoritesUseCaseTests` | Fetch, add, remove, nil remove |
| `ProductUseCaseTests` | Fetch, cache, save, **delete**, reset, categories |
| `ProductFilteringTests` | Deleted filter, category, search, brand, sort |
| `ProductEntityTests` | `isAvailable`, `ProductPage.hasMore` |
| `PaginationTests` | `PageRequest`, `PaginatedResult` |

### Manual test checklist

- [ ] Login with `demo` / `password123`
- [ ] Biometric unlock after first login
- [ ] Product list: search, filter, sort, pagination, pull-to-refresh
- [ ] Offline banner when network disabled
- [ ] Add local product (`+`), edit, **delete** (confirm both message types)
- [ ] Reset restores API catalog
- [ ] Favorites: add, swipe remove, undo
- [ ] Settings: theme, Hebrew, logout

---

## Assumptions

- DummyJSON is the product catalog; authentication is mocked locally (no auth API).
- Demo credentials are hard-coded in `AuthRepository`.
- English is default; Hebrew covers primary UI strings via string catalog.
- Local products use negative IDs and merge with API data on page one.
- Delete is local-only semantics; DummyJSON API is never modified.

## Trade-offs & Limitations

- Authentication is mocked locally.
- Pagination skip uses displayed list count (includes local-only items on page one).
- Hebrew covers UI strings; API product content stays English.
- Images for never-opened products may be unavailable offline.
- Native UIKit login animation instead of Lottie (assignment allows either).
- No XCUITest suite (optional per assignment).

---

## Deliverables Checklist

- [x] Source code
- [x] README with setup instructions
- [x] Architecture explanation
- [x] Testing credentials
- [x] AI Usage Report
- [x] Trade-offs, assumptions, and known limitations

---

## AI Usage Report

Per assignment requirements: AI tools were used during development. The candidate remains responsible for the final implementation and code quality.

| Item | Details |
|------|---------|
| **Tool** | Cursor (Claude) |
| **Assisted with** | Architecture scaffolding, file organization, Nuke integration, localization, navigation, delete flow, README, unit tests |
| **Manual review** | Repository merge logic, pagination, auth/session, offline caching, delete confirmation UX, build and test verification |

### Prompts used (3+ meaningful prompts)

1. **Architecture:** "Structure the take-home app with Clean Architecture + MVVM, route-based navigation, and separate Domain/Data/Platform layers."
2. **Organization:** "Split large view files into subfolders per screen; put ViewModels in their own folders; split mocks into separate test files."
3. **Delete UX:** "Restore local product delete with confirmation messages; present alert from tab root so it works inside NavigationStack."
4. **Documentation:** "Update README to match assignment PDF standards and expand unit testing."

### How correctness and quality were verified

- Xcode build of the `TakeHome` target
- `TakeHomeTests` unit suite (`⌘U`)
- Manual flows: login, biometrics, products (CRUD + reset), favorites (undo), settings, offline cache, delete confirmation messages (EN/HE)

---

## Author

jermaine daniel
