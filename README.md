# TakeHome — iOS Swift Take-Home Assignment

A small iOS shop app built for the **iOS Swift Take-Home Assignment**. The focus is clean architecture, scalability, maintainability, and modern Swift—not pixel-perfect UI.

watch demo here (https://drive.google.com/file/d/1iCGJ4eqMw6wiIHdAuUCTMRPpNRQ8GAz8/view?usp=sharing)

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
| **From DummyJSON** | Soft-deleted locally (`isCatalogHidden = true` on `ProductRecord`); hidden from list until **Reset** restores the API catalog |

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
| DI | Constructor injection / container | Feature-scoped modules composed by `DIContainer` |
| Networking | URLSession + Codable | `APIClient` |
| Local storage | SwiftData, UserDefaults, Keychain | SwiftData products/favorites; Keychain session; UserDefaults settings |
| Pagination | Manual cursor/limit | `PageRequest`, skip/limit paging |
| Images | AsyncImage / Nuke | **Nuke** + disk cache + prefetch |
| Testing | XCTest (XCUITest optional) | **97+ unit tests** in `TakeHomeTests` |

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

### Dependency injection

`DIContainer` is a thin composition root that wires feature-scoped modules:

| Module | Responsibility |
|--------|----------------|
| `AppInfrastructure` | SwiftData container, Nuke pipeline, network monitor |
| `AuthModule` | Auth repositories/use cases, login ViewModel factory |
| `ProductModule` | Product repositories/use cases, list/detail/editor ViewModel factories |
| `FavoritesModule` | Favorites repositories/use cases, favorites ViewModel factory |
| `SettingsModule` | Settings repositories/use cases, `AppPreferencesStore` |

`AppRouter` depends on `AppRouterDependencyProviding` (implemented by `DIContainer`) instead of the full container surface. Product and favorites flows receive `ProductModule` rather than the root container. `AuthModule` shares the same `SettingsRepository` instance as `SettingsModule`, so biometric preferences and in-app settings stay consistent.

### Product merge architecture

Offline catalog merge is split into two layers:

| Layer | Role |
|-------|------|
| `ProductMergePolicy` (Domain) | Pure functions: remote/local resolution, page-0 prepend, search merge, dedupe, total count |
| `ProductRepository` (Data) | Orchestrates API + SwiftData I/O, then delegates merge rules to the policy |

`ProductMergePolicyTests` cover merge edge cases without SwiftData. `ProductRepositoryTests` prove the full integration path (16 tests).

### Revision highlights (post-feedback)

| Feedback area | What changed |
|---------------|--------------|
| **Complex business logic** | Extracted `ProductMergePolicy` + 7 pure unit tests + 16 repository integration tests for merge/conflict/CRUD |
| **Scalable DI** | Feature modules (`AuthModule`, `ProductModule`, …), `AppRouterDependencyProviding`, shared settings repository |
| **Concurrency safety** | Production `@unchecked Sendable` removed; struct/actor repositories and `actor NukeImageLoader` |
| **Ownership signals** | Renamed `ProductRecord.isCatalogHidden` after finding SwiftData conflict with `isDeleted`; documented trade-offs |

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
├── App/                    # DIContainer, feature modules, AppPreferencesStore, AppLocalization
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   ├── Repositories/       # Protocols
│   ├── Pagination/
│   └── Utilities/          # ProductFiltering, ProductMergePolicy
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
├── Mocks/                  # Test doubles + fixtures
├── Domain/
│   ├── Entities/           # ProductEntityTests
│   ├── Utilities/          # ProductFilteringTests, ProductMergePolicyTests, PaginationTests
│   └── UseCases/           # Auth, Favorites, Product, Settings use case tests
├── Data/
│   ├── Repositories/       # AuthRepositoryTests, ProductRepositoryTests
│   └── Mappers/            # ProductMapperTests
├── Platform/               # KeychainStorageTests
└── Presentation/
    ├── Auth/               # LoginViewModelTests
    ├── Products/           # ProductListViewModelTests
    ├── Favorites/          # FavoritesViewModelTests
    └── Navigation/         # AppRouterTests
```

---

## Testing

Unit tests use **XCTest** with mock repositories in `TakeHomeTests/Mocks/`. The suite covers domain use cases, merge policy, repositories, ViewModels, navigation, filtering, pagination, and keychain persistence (97 tests).

| Test file | Coverage |
|-----------|----------|
| `ProductMergePolicyTests` | Pure merge rules: local/API conflict, prepend, search merge, dedupe, totals |
| `ProductRepositoryTests` | API/local merge integration, soft delete, search, pagination, CRUD, reset |
| `AuthUseCaseTests` | Login, logout, session, biometrics (success/unavailable/failed), `AuthError` |
| `AuthRepositoryTests` | Credential validation, session save/load/clear via in-memory keychain |
| `KeychainStorageTests` | `InMemoryKeychain` + isolated `KeychainService` round-trip |
| `FavoritesUseCaseTests` | Fetch, add, remove, nil remove |
| `FavoritesViewModelTests` | Load, remove + undo, open detail navigation |
| `ProductUseCaseTests` | Fetch, cache, save, delete, reset, categories |
| `ProductListViewModelTests` | Initial load, pagination, favorites toggle, reset, navigation |
| `LoginViewModelTests` | Validation, successful login, biometry icon, presentation mode |
| `AppRouterTests` | Delete confirmation, navigation paths, tab selection |
| `SettingsUseCaseTests` | Load/update theme, language, haptics, biometrics preference |
| `ProductMapperTests` | DTO defaults, URL parsing, SwiftData record mapping |
| `ProductFilteringTests` | Deleted filter, category, search, brand, all sort options |
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


### Work split 

| Share | What was done |
|-------|----------------|
| **~ manual (candidate)** | Assignment scoping and requirements breakdown; **architecture planning** (Clean Architecture + MVVM layer boundaries, use-case boundaries, repository contracts, navigation model); **project formation** (Xcode target setup, folder structure, dependency choices — SwiftData, Keychain, Nuke, UIKit login + SwiftUI tabs); core domain modeling (`Product`, auth models, pagination); repository merge logic (API + local SwiftData, soft vs hard delete); auth/session and biometric gating design; offline cache strategy; UX decisions (delete confirmations EN/HE, favorites undo, reset behavior); wiring `DIContainer` and `AppRouter`; code review of every AI-generated diff; manual simulator testing; test design direction and failure triage; README structure and trade-off documentation |
| **~ AI-assisted** | Boilerplate and repetitive file generation from my specs; initial view/ViewModel scaffolding; Nuke pipeline setup snippets; string-catalog entries; expanding unit tests once patterns were defined; README prose drafts; targeted bug-fix iterations when I described the exact failure (NavigationStack alert, `dismiss()` pop, Swift 6 `@MainActor` test isolation) |

### Prompts used (meaningful examples)

Prompts were **directional** — I defined the architecture and structure first; AI accelerated implementation against that plan.

1. **Architecture (from my plan):** "I already have Domain / Data / Platform / Presentation layers. Generate scaffolding for use cases and repository protocols matching this layout — do not change layer boundaries."
2. **Project formation:** "Split `ProductListView` into a subfolder with one file per section; mirror that pattern for Favorites and Auth; keep ViewModels in sibling folders."
3. **Delete UX (after I chose soft vs hard delete):** "Alert must live on `MainTabView`, not inside `navigationDestination`; two confirmation strings for local-only vs API products."
4. **Testing (after I defined coverage goals):** "Add ViewModel and `AppRouter` tests using existing mocks; follow `@MainActor` on test classes for Swift 6."


### Manual intervention (architecture, planning, and review)

- **Planned** layer dependencies (Presentation → Domain ← Data/Platform) and enforced one-way flow before any feature code.
- **Designed** navigation: tab-based `AppRouter`, separate product/favorites paths, delete confirmation at tab root to avoid SwiftUI `NavigationStack` alert bugs.
- **Defined** product lifecycle: local negative IDs, merge on page one, soft-delete for API items, hard-delete for local-only, reset to restore catalog.
- **Specified** auth flow: mocked credentials, Keychain session persistence, optional biometric unlock on launch/background.
- **Chose** tech stack and integration points (DummyJSON, SwiftData, Nuke, UIKit login animation).
- **Reviewed and corrected** every AI output — pagination skip semantics, repository caching, Hebrew RTL, haptics, and settings persistence.
- **Verified** with `⌘B` / `⌘U` and full manual flows on simulator (login, CRUD, delete messages, favorites undo, offline, theme/language).

### How correctness and quality were verified

- Xcode build of the `TakeHome` target (`⌘B`)
- `TakeHomeTests` unit suite (`⌘U`) — use cases, repositories, ViewModels, router, filtering, pagination, keychain
- Manual flows: login (`demo` / `password123`), biometrics, products (CRUD + reset + delete confirmations), favorites (swipe + undo), settings (theme/language/logout), offline cache, EN/HE strings

---

## Author

jermaine daniel
