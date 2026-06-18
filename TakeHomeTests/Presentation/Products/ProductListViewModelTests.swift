//
//  ProductListViewModelTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class ProductListViewModelTests: XCTestCase {
    private func makeViewModel(
        productRepository: MockProductRepository,
        favoritesRepository: MockFavoritesRepository
    ) -> (ProductListViewModel, DIContainer, MockProductRepository) {
        let container = DIContainer()
        let viewModel = ProductListViewModel(
            fetchProductsUseCase: FetchProductsUseCase(productRepository: productRepository),
            fetchCategoriesUseCase: FetchCategoriesUseCase(productRepository: productRepository),
            fetchFavoritesUseCase: FetchFavoritesUseCase(favoritesRepository: favoritesRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(favoritesRepository: favoritesRepository),
            resetProductsUseCase: ResetProductsUseCase(productRepository: productRepository),
            router: container.appRouter
        )
        return (viewModel, container, productRepository)
    }

    func testLoadInitially_populatesProductsAndCategories() async {
        let productRepository = MockProductRepository()
        productRepository.fetchProductsResult = ProductPage(
            products: [Product.fixture(id: 1), Product.fixture(id: 2)],
            total: 2,
            skip: 0,
            limit: 20
        )
        productRepository.categoriesResult = ["smartphones", "laptops"]

        let (viewModel, _, _) = makeViewModel(
            productRepository: productRepository,
            favoritesRepository: MockFavoritesRepository()
        )
        await viewModel.loadInitially()

        XCTAssertEqual(viewModel.products.map(\.id), [1, 2])
        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.categories, ["All", "smartphones", "laptops"])
        XCTAssertFalse(viewModel.hasMore)
    }

    func testToggleFavorite_updatesFavoriteIDs() throws {
        let favoritesRepository = MockFavoritesRepository()
        let (viewModel, _, _) = makeViewModel(
            productRepository: MockProductRepository(),
            favoritesRepository: favoritesRepository
        )

        viewModel.toggleFavorite(productID: 7)
        XCTAssertTrue(viewModel.isFavorite(productID: 7))

        viewModel.toggleFavorite(productID: 7)
        XCTAssertFalse(viewModel.isFavorite(productID: 7))
    }

    func testOpenDetail_navigatesOnProductsTab() {
        let (viewModel, container, _) = makeViewModel(
            productRepository: MockProductRepository(),
            favoritesRepository: MockFavoritesRepository()
        )

        viewModel.openDetail(productID: 3)

        XCTAssertEqual(container.appRouter.selectedTab, .products)
        XCTAssertEqual(container.appRouter.productPath.count, 1)
    }

    func testResetLocalChanges_refreshesCatalog() async     {
        let productRepository = MockProductRepository()
        productRepository.fetchProductsResult = ProductPage(
            products: [Product.fixture(id: 1)],
            total: 1,
            skip: 0,
            limit: 20
        )

        let (viewModel, _, repository) = makeViewModel(
            productRepository: productRepository,
            favoritesRepository: MockFavoritesRepository()
        )
        await viewModel.resetLocalChanges()

        XCTAssertTrue(repository.resetLocalChangesCalled)
        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.products.count, 1)
    }

    func testLoadMoreIfNeeded_appendsNextPage() async {
        let productRepository = MockProductRepository()
        productRepository.fetchProductsResult = ProductPage(
            products: [Product.fixture(id: 1)],
            total: 2,
            skip: 0,
            limit: 20
        )

        let (viewModel, _, repository) = makeViewModel(
            productRepository: productRepository,
            favoritesRepository: MockFavoritesRepository()
        )
        await viewModel.loadInitially()

        repository.fetchProductsResult = ProductPage(
            products: [Product.fixture(id: 2)],
            total: 2,
            skip: 1,
            limit: 20
        )

        await viewModel.loadMoreIfNeeded(currentProduct: viewModel.products[0])

        XCTAssertEqual(viewModel.products.map(\.id), [1, 2])
    }
}
