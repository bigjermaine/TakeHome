//
//  ProductMergePolicy.swift
//  TakeHome
//

import Foundation

/// Pure merge rules for combining API pages with local SwiftData mutations.
enum ProductMergePolicy {
    static func displayFromRemote(
        _ remoteProducts: [Product],
        localByID: [Int: Product]
    ) -> [Product] {
        remoteProducts.compactMap { remote in
            if let local = localByID[remote.id] {
                return local.isDeleted ? nil : local
            }
            return remote
        }
    }

    static func prependFirstPageLocalOnly(
        to displayProducts: [Product],
        localOnlyProducts: [Product],
        skip: Int
    ) -> [Product] {
        guard skip == 0 else { return displayProducts }

        let apiIDs = Set(displayProducts.map(\.id))
        let createdLocally = localOnlyProducts.filter {
            $0.isLocalOnly && !$0.isDeleted && $0.id < 0 && !apiIDs.contains($0.id)
        }
        return createdLocally + displayProducts
    }

    static func prependSearchLocalMatches(
        to displayProducts: [Product],
        localMatches: [Product],
        skip: Int,
        searchQuery: String?
    ) -> [Product] {
        guard skip == 0, let searchQuery, !searchQuery.isEmpty else { return displayProducts }

        let mergedIDs = Set(displayProducts.map(\.id))
        let additionalMatches = localMatches.filter { !mergedIDs.contains($0.id) }
        return additionalMatches + displayProducts
    }

    static func deduplicated(_ products: [Product]) -> [Product] {
        var seen = Set<Int>()
        return products.filter { product in
            guard seen.insert(product.id).inserted else { return false }
            return true
        }
    }

    static func totalCount(
        apiTotal: Int,
        displayCount: Int,
        searchQuery: String?
    ) -> Int {
        if let searchQuery, !searchQuery.isEmpty {
            return max(apiTotal, displayCount)
        }
        return apiTotal
    }
}
