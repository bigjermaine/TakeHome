//
//  FavoritesView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @Environment(\.locale) private var locale

    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Something Went Wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if viewModel.favorites.isEmpty {
                ContentUnavailableView(
                    "No favorites yet",
                    systemImage: "heart",
                    description: Text("Products you favorite will appear here.")
                )
            } else {
                List(viewModel.favorites) { product in
                    Button {
                        viewModel.openDetail(productID: product.id)
                    } label: {
                        FavoritesRowView(product: product)
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.remove(product: product)
                        } label: {
                            Label("Remove", systemImage: "heart.slash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.load()
        }
        .overlay(alignment: .bottom) {
            if let undoAction = viewModel.undoAction {
                UndoBanner(
                    message: String(
                        format: AppLocalization.string("Removed %@", locale: locale),
                        undoAction.product.title
                    ),
                    actionTitle: AppLocalization.string("Undo", locale: locale)
                ) {
                    viewModel.undoRemove()
                }
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel.undoAction)
    }
}
