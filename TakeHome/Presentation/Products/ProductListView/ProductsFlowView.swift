//
//  ProductsFlowView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct ProductsFlowView: View {
    let products: ProductModule
    @ObservedObject var viewModel: ProductListViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.productPath) {
            ProductListView(viewModel: viewModel)
                .onChange(of: router.productPath.count) { oldCount, newCount in
                    if newCount < oldCount {
                        viewModel.reloadFromCache()
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
