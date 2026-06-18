//
//  MainTabView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct MainTabView: View {
    let products: ProductModule
    let favorites: FavoritesModule
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var preferences: AppPreferencesStore

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ProductsFlowView(
                products: products,
                viewModel: products.makeProductListViewModel()
            )
            .tabItem {
                Label(localized("Products"), systemImage: "square.grid.2x2")
            }
            .tag(TabRoute.products)

            FavoritesFlowView(
                products: products,
                viewModel: favorites.makeFavoritesViewModel()
            )
                .tabItem {
                    Label(localized("Favorites"), systemImage: "heart")
                }
                .tag(TabRoute.favorites)

            SettingsView()
                .id(preferences.language)
                .tabItem {
                    Label(localized("Settings"), systemImage: "gearshape")
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
