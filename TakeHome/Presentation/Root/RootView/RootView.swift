//
//  RootView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

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
                    viewModel: container.auth.makeLoginViewModel(),
                    locale: preferences.locale,
                    loginMode: router.loginMode
                )
                .ignoresSafeArea()
            case .main:
                MainTabView(
                    products: container.products,
                    favorites: container.favorites
                )
            }
        }
        .preferredColorScheme(preferences.preferredColorScheme)
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

#Preview {
    let container = DIContainer()
    RootView(container: container)
        .environmentObject(container.appRouter)
        .environmentObject(container.appPreferencesStore)
        .environment(\.locale, container.appPreferencesStore.locale)
}
