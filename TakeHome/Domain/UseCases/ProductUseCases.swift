//
//  ProductUseCases.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

struct FetchProductsUseCase: Sendable {
    private let productRepository: ProductRepositoryProtocol

    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }

    func cached(
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) throws -> [Product] {
        try productRepository.cachedProducts(
            searchQuery: searchQuery,
            category: category,
            sort: sort
        )
    }

    func execute(
        skip: Int,
        limit: Int,
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) async throws -> ProductPage {
        try await productRepository.fetchProducts(
            skip: skip,
            limit: limit,
            searchQuery: searchQuery,
            category: category,
            sort: sort
        )
    }
}

struct FetchProductDetailUseCase: Sendable {
    private let productRepository: ProductRepositoryProtocol

    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }

    func execute(id: Int) async throws -> Product {
        try await productRepository.fetchProduct(id: id)
    }
}

struct SaveProductUseCase: Sendable {
    private let productRepository: ProductRepositoryProtocol

    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }

    func execute(_ product: Product) async throws {
        try await productRepository.saveProduct(product)
    }
}

struct DeleteProductUseCase: Sendable {
    private let productRepository: ProductRepositoryProtocol

    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }

    func execute(id: Int) async throws {
        try await productRepository.deleteProduct(id: id)
    }
}

struct ResetProductsUseCase: Sendable {
    private let productRepository: ProductRepositoryProtocol

    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }

    func execute() async throws {
        try await productRepository.resetLocalChanges()
    }
}

struct FetchCategoriesUseCase: Sendable {
    private let productRepository: ProductRepositoryProtocol

    init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }

    func execute() throws -> [String] {
        try productRepository.categories()
    }
}
