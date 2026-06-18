//
//  ProductListView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct ProductListView: View {
    @ObservedObject var viewModel: ProductListViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @Environment(\.locale) private var locale

    var body: some View {
        List {
            if !networkMonitor.isConnected {
                Section {
                    Label(localized("You're offline. Showing cached products."), systemImage: "wifi.slash")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            filtersSection
            contentSection
        }
        .localizedNavigationTitle(localized("Products"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(localized("Reset")) {
                    HapticFeedback.play(.warning)
                    Task { await viewModel.resetLocalChanges() }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticFeedback.play(.light)
                    viewModel.openCreateProduct()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: Text(localized("Search products")))
        .onSubmit(of: .search) {
            Task { await viewModel.applyFilters() }
        }
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.scheduleSearch()
        }
        .task {
            await viewModel.loadInitially()
        }
        .refreshable {
            await viewModel.refresh(showLoadingUI: false, successHaptic: true)
        }
    }

    func localized(_ key: String) -> String {
        AppLocalization.string(key, locale: locale)
    }
}
