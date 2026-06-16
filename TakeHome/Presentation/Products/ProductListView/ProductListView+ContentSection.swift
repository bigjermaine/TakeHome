//
//  ProductListView+ContentSection.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

extension ProductListView {
    @ViewBuilder
    var contentSection: some View {
        if viewModel.isSearching && viewModel.products.isEmpty {
            statusSection(
                title: localized("Searching…"),
                systemImage: "magnifyingglass",
                description: String(format: localized("Looking for \"%@\""), viewModel.searchQuery)
            ) {
                ProgressView()
                    .padding(.top, 8)
            }
        } else if viewModel.viewState == .loading && viewModel.products.isEmpty {
            statusSection(
                title: localized("Loading Products"),
                systemImage: "bag",
                description: localized("Fetching the latest catalog.")
            ) {
                ProgressView()
                    .padding(.top, 8)
            }
        } else if case .error(let message) = viewModel.viewState, viewModel.products.isEmpty {
            statusSection(
                title: localized("Something Went Wrong"),
                systemImage: "exclamationmark.triangle",
                description: message
            ) {
                Button("Try Again") {
                    Task { await viewModel.refresh(showLoadingUI: true) }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        } else if viewModel.products.isEmpty {
            statusSection(
                title: emptyStateTitle,
                systemImage: emptyStateIcon,
                description: emptyStateDescription
            ) {
                if viewModel.isSearchActive {
                    Button("Clear Search") {
                        viewModel.searchQuery = ""
                        Task { await viewModel.applyFilters() }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }
        } else {
            productsSection
        }
    }

    var emptyStateTitle: String {
        if viewModel.isSearchActive {
            return localized("No Results Found")
        }
        if viewModel.selectedCategory != "All" {
            return localized("No Products in Category")
        }
        return localized("No Products Yet")
    }

    var emptyStateIcon: String {
        viewModel.isSearchActive ? "magnifyingglass" : "bag"
    }

    var emptyStateDescription: String {
        if viewModel.isSearchActive {
            return localized("Try another keyword or clear your filters.")
        }
        if viewModel.selectedCategory != "All" {
            return localized("No products match the selected category.")
        }
        return localized("Pull to refresh or add a new product.")
    }

    func statusSection<Actions: View>(
        title: String,
        systemImage: String,
        description: String,
        @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) -> some View {
        Section {
            VStack(spacing: 12) {
                ContentUnavailableView(title, systemImage: systemImage, description: Text(description))
                actions()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .listRowBackground(Color.clear)
        }
    }
}
