//
//  FavoritesRowView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct FavoritesRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            ProductImageView(url: product.thumbnailURL)
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline)
            }
        }
    }
}
