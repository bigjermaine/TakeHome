//
//  MockFavoritesRepository.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
@testable import TakeHome

final class MockFavoritesRepository: FavoritesRepositoryProtocol, @unchecked Sendable {
    var favorites: [Product] = []
    private var favoriteIDs: Set<Int> = []

    func fetchFavorites() throws -> [Product] {
        favorites
    }

    func isFavorite(productID: Int) throws -> Bool {
        favoriteIDs.contains(productID)
    }

    func addFavorite(productID: Int) throws {
        favoriteIDs.insert(productID)
    }

    func removeFavorite(productID: Int) throws -> Product? {
        guard favoriteIDs.contains(productID) else { return nil }
        favoriteIDs.remove(productID)
        return favorites.first { $0.id == productID }
    }
}
