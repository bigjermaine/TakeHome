//
//  FavoritesFlowView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct FavoritesFlowView: View {
    let products: ProductModule
    @ObservedObject var viewModel: FavoritesViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.favoritesPath) {
            FavoritesView(viewModel: viewModel)
                .onChange(of: router.favoritesPath.count) { oldCount, newCount in
                    if newCount < oldCount {
                        viewModel.load()
                    }
                }
                .navigationDestination(for: ProductRoute.self) { route in
                    switch route {
                    case .detail(let productID):
                        ProductDetailView(
                            viewModel: products.makeProductDetailViewModel(productID: productID)
                        )
                        .id(productID)
                    case .editor(let productID):
                        ProductEditorView(
                            viewModel: products.makeProductEditorViewModel(productID: productID)
                        )
                    }
                }
        }
    }
}
