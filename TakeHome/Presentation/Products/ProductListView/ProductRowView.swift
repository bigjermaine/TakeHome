//
//  ProductRowView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct ProductRowView: View {
    let product: Product
    let isFavorite: Bool
    let onFavoriteTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProductImageView(url: product.thumbnailURL)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(product.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline.bold())
            }

            Spacer()

            Button(action: onFavoriteTapped) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
