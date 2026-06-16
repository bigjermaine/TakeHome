//
//  ProductsFlowView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct ProductsFlowView: View {
    let container: DIContainer
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
                            viewModel: container.makeProductDetailViewModel(productID: productID)
                        )
                        .id(productID)
                    case .editor(let productID):
                        ProductEditorView(
                            viewModel: container.makeProductEditorViewModel(productID: productID)
                        )
                    }
                }
        }
    }
}
