//
//  ProductFiltering.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

enum ProductFiltering {
    static func apply(
        to products: [Product],
        searchQuery: String?,
        category: String?,
        sortOption: ProductSortOption
    ) -> [Product] {
        var filtered = products.filter { !$0.isDeleted }

        if let category, !category.isEmpty, category != "All" {
            filtered = filtered.filter { $0.category == category }
        }

        if let searchQuery, !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter {
                $0.title.lowercased().contains(query)
                    || $0.brand.lowercased().contains(query)
                    || $0.category.lowercased().contains(query)
            }
        }

        return sort(products: filtered, by: sortOption)
    }

    static func sort(products: [Product], by option: ProductSortOption) -> [Product] {
        switch option {
        case .titleAscending:
            products.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            products.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .priceAscending:
            products.sorted { $0.price < $1.price }
        case .priceDescending:
            products.sorted { $0.price > $1.price }
        case .ratingDescending:
            products.sorted { $0.rating > $1.rating }
        }
    }
}
