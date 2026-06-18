//
//  FavoritesRepository.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

@MainActor
final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let favoritesLocalDataSource: FavoritesLocalDataSource
    private let productLocalDataSource: ProductLocalDataSource

    init(
        favoritesLocalDataSource: FavoritesLocalDataSource,
        productLocalDataSource: ProductLocalDataSource
    ) {
        self.favoritesLocalDataSource = favoritesLocalDataSource
        self.productLocalDataSource = productLocalDataSource
    }

    func fetchFavorites() throws -> [Product] {
        let ids = try favoritesLocalDataSource.favoriteIDs()
        return ids.compactMap { id in
            guard let record = try? productLocalDataSource.record(id: id), !record.isCatalogHidden else {
                return nil
            }
            return ProductMapper.map(record)
        }
    }

    func isFavorite(productID: Int) throws -> Bool {
        try favoritesLocalDataSource.isFavorite(productID: productID)
    }

    func addFavorite(productID: Int) throws {
        try favoritesLocalDataSource.add(productID: productID)
    }

    func removeFavorite(productID: Int) throws -> Product? {
        guard try favoritesLocalDataSource.isFavorite(productID: productID) else {
            return nil
        }
        let product = try productLocalDataSource.record(id: productID).map(ProductMapper.map)
        try favoritesLocalDataSource.remove(productID: productID)
        return product
    }
}
