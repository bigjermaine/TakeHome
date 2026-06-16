//
//  ProductDetailView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductDetailViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.locale) private var locale

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let product):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ProductImageView(url: product.thumbnailURL, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)

                        if !product.imageURLs.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(product.imageURLs, id: \.absoluteString) { url in
                                        ProductImageView(url: url)
                                            .frame(width: 88, height: 88)
                                    }
                                }
                            }
                        }

                        Text(product.title)
                            .font(.title2.bold())

                        HStack {
                            Text(product.price, format: .currency(code: "USD"))
                                .font(.title3.bold())
                            Spacer()
                            Label(String(format: "%.1f", product.rating), systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                        }

                        Label(product.category, systemImage: "tag")
                        Label(product.brand, systemImage: "building.2")
                        Label(
                            String(
                                format: AppLocalization.string("Stock: %lld", locale: locale),
                                Int64(product.stock)
                            ),
                            systemImage: "shippingbox"
                        )

                        if product.isLocalOnly {
                            Text("Local product")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.orange.opacity(0.15))
                                .clipShape(Capsule())
                        }

                        Text(product.productDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            case .error(let messageKey):
                ContentUnavailableView(
                    "Unable to load product",
                    systemImage: "exclamationmark.triangle",
                    description: Text(AppLocalization.string(messageKey, locale: locale))
                )
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? .red : .primary)
                }

                Button("Edit") {
                    HapticFeedback.play(.light)
                    viewModel.openEditor()
                }
            }
        }
        .onAppear {
            Task { await viewModel.load() }
        }
        .onChange(of: router.productPath.count) { oldCount, newCount in
            if newCount < oldCount {
                Task { await viewModel.load() }
            }
        }
    }
}
