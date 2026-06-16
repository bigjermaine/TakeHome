//
//  FavoritesLocalDataSource.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class FavoritesLocalDataSource {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func favoriteIDs() throws -> [Int] {
        let descriptor = FetchDescriptor<FavoriteRecord>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(\.productID)
    }

    func isFavorite(productID: Int) throws -> Bool {
        let descriptor = FetchDescriptor<FavoriteRecord>(
            predicate: #Predicate { $0.productID == productID }
        )
        return try !modelContext.fetch(descriptor).isEmpty
    }

    func add(productID: Int) throws {
        guard try !isFavorite(productID: productID) else { return }
        modelContext.insert(FavoriteRecord(productID: productID))
        try modelContext.save()
    }

    func remove(productID: Int) throws {
        let descriptor = FetchDescriptor<FavoriteRecord>(
            predicate: #Predicate { $0.productID == productID }
        )
        for record in try modelContext.fetch(descriptor) {
            modelContext.delete(record)
        }
        try modelContext.save()
    }
}
