//
//  ProductEditorView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct ProductEditorView: View {
    @ObservedObject var viewModel: ProductEditorViewModel
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Title", text: $viewModel.title)
                TextField("Description", text: $viewModel.productDescription, axis: .vertical)
                TextField("Category", text: $viewModel.category)
                TextField("Brand", text: $viewModel.brand)
            }

            Section("Pricing & Inventory") {
                TextField("Price", text: $viewModel.price)
                    .keyboardType(.decimalPad)
                TextField("Stock", text: $viewModel.stock)
                    .keyboardType(.numberPad)
                TextField("Rating", text: $viewModel.rating)
                    .keyboardType(.decimalPad)
            }

            Section("Image") {
                TextField("Thumbnail URL", text: $viewModel.thumbnailURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if case .error(let messageKey) = viewModel.viewState {
                Section {
                    Text(AppLocalization.string(messageKey, locale: locale))
                        .foregroundStyle(.red)
                }
            }
        }
        .localizedNavigationTitle(
            localized(viewModel.isEditingExisting ? "Edit Product" : "Add Product")
        )
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(localized("Save")) {
                    HapticFeedback.play(.light)
                    Task {
                        if await viewModel.save() {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.viewState == .saving)
            }
        }
        .overlay {
            if viewModel.viewState == .loading || viewModel.viewState == .saving {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func localized(_ key: String) -> String {
        AppLocalization.string(key, locale: locale)
    }
}
