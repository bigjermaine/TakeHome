import SwiftUI
import SwiftData

@main
struct TakeHomeApp: App {
    @State private var container = DIContainer()

    var body: some Scene {
        WindowGroup {
            AppContentView(container: container)
                .environmentObject(container.appRouter)
                .environmentObject(container.appPreferencesStore)
                .environmentObject(container.networkMonitor)
                .modelContainer(container.modelContainer)
        }
    }
}

private struct AppContentView: View {
    let container: DIContainer
    @EnvironmentObject private var preferences: AppPreferencesStore

    var body: some View {
        RootView(container: container)
            .environment(\.locale, preferences.locale)
            .id(preferences.language)
    }
}
