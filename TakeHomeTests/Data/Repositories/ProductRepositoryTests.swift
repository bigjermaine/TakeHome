//
//  ProductRepositoryTests.swift
//  TakeHomeTests
//

import XCTest
import SwiftData
@testable import TakeHome

@MainActor
final class ProductRepositoryTests: XCTestCase {
    private func makeSUT(
        configureRemote: (MockProductRemoteDataSource) -> Void = { _ in }
    ) throws -> (ProductRepository, ProductLocalDataSource, MockProductRemoteDataSource) {
        let remote = MockProductRemoteDataSource()
        configureRemote(remote)
        let schema = Schema([ProductRecord.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(container)
        let local = ProductLocalDataSource(modelContext: context)
        let repository = ProductRepository(remoteDataSource: remote, localDataSource: local)
        return (repository, local, remote)
    }

    // MARK: - Remote + local display merge

    func testFetchProducts_softDeletedAPIProduct_isHiddenFromPage() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1, title: "Phone")],
                total: 1,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: 1, title: "Phone"))
        try await repository.deleteProduct(id: 1)

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertTrue(page.products.isEmpty)
    }

    func testFetchProducts_localEditWinsOverAPIRefresh() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1, title: "API Title")],
                total: 1,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: 1, title: "Local Title", isLocalOnly: true))

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.map(\.title), ["Local Title"])
    }

    func testFetchProducts_apiUpdatesNonLocalRecord() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1, title: "Updated", price: 99)],
                total: 1,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: 1, title: "Original", price: 10))

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.first?.title, "Updated")
        XCTAssertEqual(page.products.first?.price, 99)
    }

    func testFetchProducts_upsertMany_skipsLocalOnlyRecords() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1, title: "API", price: 50)],
                total: 1,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: 1, title: "Local Edit", price: 12, isLocalOnly: true))

        _ = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        let stored = try local.record(id: 1).map(ProductMapper.map)
        XCTAssertEqual(stored?.title, "Local Edit")
        XCTAssertEqual(stored?.price, 12)
    }

    // MARK: - Page-0 local prepend

    func testFetchProducts_prependsLocalOnlyNegativeIDsOnFirstPage() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1), .fixture(id: 2)],
                total: 2,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: -1, title: "Local A", isLocalOnly: true))
        try local.upsert(.fixture(id: -2, title: "Local B", isLocalOnly: true))

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.map(\.id), [-1, -2, 1, 2])
    }

    func testFetchProducts_doesNotPrependLocalOnlyOnPagination() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 3)],
                total: 3,
                skip: 20,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: -1, title: "Local", isLocalOnly: true))

        let page = try await repository.fetchProducts(
            skip: 20,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.map(\.id), [3])
    }

    func testFetchProducts_excludesDeletedLocalOnlyFromPrepend() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1)],
                total: 1,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: -1, title: "Deleted Local", isLocalOnly: true))
        try await repository.deleteProduct(id: -1)

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: nil,
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.map(\.id), [1])
    }

    // MARK: - Search merge

    func testFetchProducts_searchPrependsLocalMatchesMissingFromAPI() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.searchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1, title: "iPhone")],
                total: 1,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: -5, title: "Custom iPhone Case", isLocalOnly: true))

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: "iphone",
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.map(\.id), [-5, 1])
    }

    func testFetchProducts_searchDoesNotDuplicateProductsAlreadyInAPIResults() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.searchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1, title: "iPhone")],
                total: 1,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: 1, title: "Edited iPhone", isLocalOnly: true))

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: "iphone",
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.count, 1)
        XCTAssertEqual(page.products.first?.id, 1)
    }

    func testFetchProducts_searchTotalUsesMaxOfAPIAndDisplayCount() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.searchProductsResult = ProductsResponseDTO(
                products: [.fixture(id: 1, title: "iPhone")],
                total: 5,
                skip: 0,
                limit: 20
            )
        }
        try local.upsert(.fixture(id: -1, title: "iPhone Stand", isLocalOnly: true))
        try local.upsert(.fixture(id: -2, title: "iPhone Cable", isLocalOnly: true))

        let page = try await repository.fetchProducts(
            skip: 0,
            limit: 20,
            searchQuery: "iphone",
            category: nil,
            sort: .titleAscending
        )

        XCTAssertEqual(page.products.count, 3)
        XCTAssertEqual(page.total, 5)
    }

    // MARK: - CRUD + reset

    func testSaveProduct_withZeroID_assignsNegativeLocalID() async throws {
        let (repository, local, _) = try makeSUT()
        let newProduct = Product.fixture(id: 0, title: "New Local", isLocalOnly: false)

        try await repository.saveProduct(newProduct)

        let records = try local.allRecords()
        XCTAssertEqual(records.count, 1)
        XCTAssertTrue(records[0].id < 0)
        XCTAssertTrue(records[0].isLocalOnly)
        XCTAssertEqual(records[0].title, "New Local")
    }

    func testDeleteProduct_apiProduct_softDeletesLocally() async throws {
        let (repository, local, _) = try makeSUT()
        try local.upsert(.fixture(id: 10, title: "API Product"))

        try await repository.deleteProduct(id: 10)

        let record = try local.record(id: 10)
        XCTAssertNotNil(record)
        XCTAssertTrue(record?.isCatalogHidden == true)
        XCTAssertFalse(record?.isLocalOnly == true)
    }

    func testDeleteProduct_localOnlyProduct_hardDeletes() async throws {
        let (repository, local, _) = try makeSUT()
        try local.upsert(.fixture(id: -3, title: "Local", isLocalOnly: true))

        try await repository.deleteProduct(id: -3)

        XCTAssertNil(try local.record(id: -3))
    }

    func testFetchProduct_softDeleted_throwsNotFound() async throws {
        let (repository, local, _) = try makeSUT()
        try local.upsert(.fixture(id: 7, title: "Hidden"))
        try await repository.deleteProduct(id: 7)

        do {
            _ = try await repository.fetchProduct(id: 7)
            XCTFail("Expected productNotFound")
        } catch let error as ProductRepositoryError {
            XCTAssertEqual(error, .productNotFound)
        }
    }

    func testResetLocalChanges_clearsLocalMutationsAndReloadsFromRemote() async throws {
        let (repository, local, _) = try makeSUT { remote in
            remote.fetchAllProductsResult = [.fixture(id: 1, title: "Fresh")]
        }
        try local.upsert(.fixture(id: -1, title: "Local", isLocalOnly: true))
        try local.upsert(.fixture(id: 2, title: "Deleted"))
        try await repository.deleteProduct(id: 2)

        try await repository.resetLocalChanges()

        XCTAssertNil(try local.record(id: -1))
        XCTAssertNil(try local.record(id: 2))
        let restored = try local.record(id: 1).map(ProductMapper.map)
        XCTAssertEqual(restored?.title, "Fresh")
    }

    func testCachedProducts_appliesFiltering() throws {
        let (repository, local, _) = try makeSUT()
        try local.upsert(.fixture(id: 1, title: "Alpha", category: "phones"))
        try local.upsert(.fixture(id: 2, title: "Beta", category: "laptops"))
        try local.upsert(.fixture(id: 3, title: "Hidden", isDeleted: true))

        let filtered = try repository.cachedProducts(
            searchQuery: "alp",
            category: "phones",
            sort: .titleAscending
        )

        XCTAssertEqual(filtered.map(\.id), [1])
    }
}
