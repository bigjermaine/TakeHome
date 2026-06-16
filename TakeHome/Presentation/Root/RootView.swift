import SwiftUI

struct RootView: View {
    let container: DIContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var preferences: AppPreferencesStore
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch router.appRoute {
            case .login:
                LoginViewControllerWrapper(
                    viewModel: container.makeLoginViewModel(),
                    locale: preferences.locale,
                    loginMode: router.loginMode
                )
                .ignoresSafeArea()
            case .main:
                MainTabView(container: container)
            }
        }
        .preferredColorScheme(preferences.preferredColorScheme)
        .task {
            await router.bootstrap()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                router.prepareForBackgroundLock()
            case .active:
                router.lockAppIfNeeded()
            default:
                break
            }
        }
    }
}

struct MainTabView: View {
    let container: DIContainer
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ProductsFlowView(
                container: container,
                viewModel: container.makeProductListViewModel()
            )
            .tabItem {
                Label("Products", systemImage: "square.grid.2x2")
            }
            .tag(TabRoute.products)

            FavoritesFlowView(
                container: container,
                viewModel: container.makeFavoritesViewModel()
            )
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(TabRoute.favorites)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(TabRoute.settings)
        }
        .onChange(of: router.selectedTab) { _, _ in
            HapticFeedback.play(.selection)
        }
    }
}

#Preview {
    let container = DIContainer()
    RootView(container: container)
        .environmentObject(container.appRouter)
        .environmentObject(container.appPreferencesStore)
        .environment(\.locale, container.appPreferencesStore.locale)
}
