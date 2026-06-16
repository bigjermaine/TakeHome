//
//  FavoritesViewModelTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    private func makeViewModel(
        favoritesRepository: MockFavoritesRepository = MockFavoritesRepository()
    ) -> (FavoritesViewModel, DIContainer, MockFavoritesRepository) {
        let container = DIContainer()
        let fetchUseCase = FetchFavoritesUseCase(favoritesRepository: favoritesRepository)
        let toggleUseCase = ToggleFavoriteUseCase(favoritesRepository: favoritesRepository)
        let viewModel = FavoritesViewModel(
            fetchFavoritesUseCase: fetchUseCase,
            toggleFavoriteUseCase: toggleUseCase,
            router: container.appRouter
        )
        return (viewModel, container, favoritesRepository)
    }

    func testLoad_populatesFavorites() {
        let repository = MockFavoritesRepository()
        repository.favorites = [
            Product.fixture(id: 1, title: "Phone"),
            Product.fixture(id: 2, title: "Laptop")
        ]
        let (viewModel, _, _) = makeViewModel(favoritesRepository: repository)

        viewModel.load()

        XCTAssertEqual(viewModel.favorites.map(\.id), [1, 2])
        XCTAssertNil(viewModel.errorMessage)
    }

    func testRemove_presentsUndoAndUpdatesList() throws {
        let repository = MockFavoritesRepository()
        let product = Product.fixture(id: 5, title: "Watch")
        repository.favorites = [product]
        try repository.addFavorite(productID: 5)

        let (viewModel, _, _) = makeViewModel(favoritesRepository: repository)
        viewModel.load()

        viewModel.remove(product: product)

        XCTAssertTrue(viewModel.favorites.isEmpty)
        XCTAssertEqual(viewModel.undoAction?.product.id, 5)
    }

    func testUndoRemove_restoresFavorite() throws {
        let repository = MockFavoritesRepository()
        let product = Product.fixture(id: 5, title: "Watch")
        repository.favorites = [product]
        try repository.addFavorite(productID: 5)

        let (viewModel, _, _) = makeViewModel(favoritesRepository: repository)
        viewModel.load()
        viewModel.remove(product: product)
        viewModel.undoRemove()

        XCTAssertEqual(viewModel.favorites.map(\.id), [5])
        XCTAssertNil(viewModel.undoAction)
    }

    func testOpenDetail_navigatesOnFavoritesTab() {
        let (viewModel, container, _) = makeViewModel()

        viewModel.openDetail(productID: 9)

        XCTAssertEqual(container.appRouter.selectedTab, .favorites)
        XCTAssertEqual(container.appRouter.favoritesPath.count, 1)
    }
}
