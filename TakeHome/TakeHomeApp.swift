//
//  TakeHomeApp.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

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
            .task {
                await container.appRouter.bootstrapIfNeeded()
            }
    }
}
