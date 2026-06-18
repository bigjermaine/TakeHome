//
//  FavoritesUseCaseTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class FavoritesUseCaseTests: XCTestCase {
    private var repository: MockFavoritesRepository!
    private var fetchUseCase: FetchFavoritesUseCase!
    private var toggleUseCase: ToggleFavoriteUseCase!

    override func setUp() {
        super.setUp()
        repository = MockFavoritesRepository()
        fetchUseCase = FetchFavoritesUseCase(favoritesRepository: repository)
        toggleUseCase = ToggleFavoriteUseCase(favoritesRepository: repository)
    }

    func testFetchFavorites_returnsStoredProducts() throws {
        repository.favorites = [
            .fixture(id: 1, title: "Phone"),
            .fixture(id: 2, title: "Laptop")
        ]

        let favorites = try fetchUseCase.execute()

        XCTAssertEqual(favorites.map(\.id), [1, 2])
    }

    func testToggleFavorite_addMarksProductAsFavorite() throws {
        try toggleUseCase.add(productID: 42)

        XCTAssertTrue(try toggleUseCase.isFavorite(productID: 42))
    }

    func testToggleFavorite_removeReturnsProduct() throws {
        let product = Product.fixture(id: 7, title: "Watch")
        repository.favorites = [product]
        try toggleUseCase.add(productID: 7)

        let removed = try toggleUseCase.remove(productID: 7)

        XCTAssertEqual(removed?.id, 7)
        XCTAssertFalse(try toggleUseCase.isFavorite(productID: 7))
    }

    func testToggleFavorite_removeReturnsNilWhenNotFavorite() throws {
        let removed = try toggleUseCase.remove(productID: 99)

        XCTAssertNil(removed)
    }
}
