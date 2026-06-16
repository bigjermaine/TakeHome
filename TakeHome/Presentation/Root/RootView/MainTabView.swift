//
//  MainTabView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct MainTabView: View {
    let container: DIContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var preferences: AppPreferencesStore

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
        .alert(
            localized("Delete this product?"),
            isPresented: Binding(
                get: { router.isDeleteConfirmationPresented },
                set: { router.isDeleteConfirmationPresented = $0 }
            )
        ) {
            Button(localized("Delete"), role: .destructive) {
                guard let productID = router.deleteConfirmationProductID else { return }
                router.dismissDeleteConfirmation()
                HapticFeedback.play(.heavy)
                Task { await router.confirmDeleteProduct(productID: productID) }
            }
            Button(localized("Cancel"), role: .cancel) {
                router.dismissDeleteConfirmation()
            }
        } message: {
            Text(deleteConfirmationMessage)
        }
    }

    private var deleteConfirmationMessage: String {
        if router.deleteConfirmationIsLocalOnly {
            return localized(
                "This locally created product will be permanently removed from your device."
            )
        }
        return localized(
            "This product will be hidden from your catalog until you reset local changes."
        )
    }

    private func localized(_ key: String) -> String {
        AppLocalization.string(key, locale: preferences.locale)
    }
}
