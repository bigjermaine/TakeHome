//
//  ProductListView+FiltersSection.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

extension ProductListView {
    var filtersSection: some View {
        Section {
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .onChange(of: viewModel.selectedCategory) { _, _ in
                HapticFeedback.play(.selection)
                Task { await viewModel.applyFilters() }
            }

            Picker("Sort", selection: $viewModel.sortOption) {
                Text("Title A-Z").tag(ProductSortOption.titleAscending)
                Text("Title Z-A").tag(ProductSortOption.titleDescending)
                Text("Price Low-High").tag(ProductSortOption.priceAscending)
                Text("Price High-Low").tag(ProductSortOption.priceDescending)
                Text("Top Rated").tag(ProductSortOption.ratingDescending)
            }
            .onChange(of: viewModel.sortOption) { _, _ in
                HapticFeedback.play(.selection)
                Task { await viewModel.applyFilters() }
            }
        }
    }
}
