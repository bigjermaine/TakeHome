//
//  MockProductRepository.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
@testable import TakeHome

final class MockProductRepository: ProductRepositoryProtocol, @unchecked Sendable {
    var cachedProductsResult: [Product] = []
    var fetchProductsResult: ProductPage = ProductPage(
        products: [],
        total: 0,
        skip: 0,
        limit: 20
    )
    var fetchProductResult: Product?
    var fetchProductError: Error?
    var saveProductCalled = false
    var deleteProductCalled = false
    var resetLocalChangesCalled = false
    var categoriesResult: [String] = []

    func cachedProducts(
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) throws -> [Product] {
        cachedProductsResult
    }

    func fetchProducts(
        skip: Int,
        limit: Int,
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) async throws -> ProductPage {
        fetchProductsResult
    }

    func fetchProduct(id: Int) async throws -> Product {
        if let error = fetchProductError {
            throw error
        }
        guard let product = fetchProductResult else {
            throw NSError(domain: "MockProductRepository", code: 404)
        }
        return product
    }

    func saveProduct(_ product: Product) async throws {
        saveProductCalled = true
    }

    func deleteProduct(id: Int) async throws {
        deleteProductCalled = true
    }

    func resetLocalChanges() async throws {
        resetLocalChangesCalled = true
    }

    func categories() throws -> [String] {
        categoriesResult
    }
}
