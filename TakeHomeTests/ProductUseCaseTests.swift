//
//  ProductUseCaseTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class ProductUseCaseTests: XCTestCase {
    func testFetchProductsUseCase_returnsRepositoryPage() async throws {
        let repository = MockProductRepository()
        repository.fetchProductsResult = ProductPage(
            products: [.fixture(id: 1), .fixture(id: 2)],
            total: 100,
            skip: 0,
            limit: 20
        )
        let useCase = FetchProductsUseCase(productRepository: repository)

        let page = try await useCase.execute(
            skip: 0,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.count, 2)
        XCTAssertTrue(page.hasMore)
    }

    func testFetchProductsUseCase_cachedReadsLocalSnapshot() throws {
        let repository = MockProductRepository()
        repository.cachedProductsResult = [.fixture(id: 3, title: "Cached")]
        let useCase = FetchProductsUseCase(productRepository: repository)

        let cached = try useCase.cached(
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(cached.map(\.id), [3])
    }

    func testSaveProductUseCase_persistsThroughRepository() async throws {
        let repository = MockProductRepository()
        let useCase = SaveProductUseCase(productRepository: repository)
        let product = Product.fixture(id: -1, title: "Local", isLocalOnly: true)

        try await useCase.execute(product)

        XCTAssertTrue(repository.saveProductCalled)
    }

    func testResetProductsUseCase_clearsLocalChanges() async throws {
        let repository = MockProductRepository()
        let useCase = ResetProductsUseCase(productRepository: repository)

        try await useCase.execute()

        XCTAssertTrue(repository.resetLocalChangesCalled)
    }

    func testDeleteProductUseCase_deletesThroughRepository() async throws {
        let repository = MockProductRepository()
        let useCase = DeleteProductUseCase(productRepository: repository)

        try await useCase.execute(id: 42)

        XCTAssertTrue(repository.deleteProductCalled)
    }

    func testFetchCategoriesUseCase_returnsRepositoryCategories() throws {
        let repository = MockProductRepository()
        repository.categoriesResult = ["phones", "laptops"]
        let useCase = FetchCategoriesUseCase(productRepository: repository)

        let categories = try useCase.execute()

        XCTAssertEqual(categories, ["phones", "laptops"])
    }
}
