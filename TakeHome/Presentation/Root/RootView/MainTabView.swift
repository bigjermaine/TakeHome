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
