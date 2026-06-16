//
//  ProductListView+ProductsSection.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

extension ProductListView {
    var productsSection: some View {
        Section {
            if viewModel.isSearching {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Searching…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.products) { product in
                Button {
                    viewModel.openDetail(productID: product.id)
                } label: {
                    ProductRowView(
                        product: product,
                        isFavorite: viewModel.isFavorite(productID: product.id),
                        onFavoriteTapped: {
                            viewModel.toggleFavorite(productID: product.id)
                        }
                    )
                }
                .buttonStyle(.plain)
                .onAppear {
                    Task { await viewModel.loadMoreIfNeeded(currentProduct: product) }
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }
}
