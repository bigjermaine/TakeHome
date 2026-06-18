//
//  ProductRepository.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

enum ProductRepositoryError: LocalizedError, Equatable {
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found."
        }
    }
}

@MainActor
final class ProductRepository: ProductRepositoryProtocol {
    private let remoteDataSource: ProductRemoteDataSourcing
    private let localDataSource: ProductLocalDataSource

    init(
        remoteDataSource: ProductRemoteDataSourcing,
        localDataSource: ProductLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func cachedProducts(
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) throws -> [Product] {
        let products = try localDataSource.allRecords().map(ProductMapper.map)
        return ProductFiltering.apply(
            to: products,
            searchQuery: searchQuery,
            category: category,
            sortOption: sort
        )
    }

    func fetchProducts(
        skip: Int,
        limit: Int,
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) async throws -> ProductPage {
        let response: ProductsResponseDTO
        if let searchQuery, !searchQuery.isEmpty {
            response = try await remoteDataSource.searchProducts(
                query: searchQuery,
                skip: skip,
                limit: limit
            )
        } else {
            response = try await remoteDataSource.fetchProducts(skip: skip, limit: limit)
        }

        let remoteProducts = response.products.map { ProductMapper.map($0) }
        try localDataSource.upsertMany(remoteProducts)

        let allLocalProducts = try localDataSource.allRecords().map(ProductMapper.map)
        let localByID = Dictionary(uniqueKeysWithValues: allLocalProducts.map { ($0.id, $0) })
        var displayProducts = ProductMergePolicy.displayFromRemote(
            remoteProducts,
            localByID: localByID
        )

        displayProducts = ProductMergePolicy.prependFirstPageLocalOnly(
            to: displayProducts,
            localOnlyProducts: allLocalProducts,
            skip: skip
        )

        if skip == 0, let searchQuery, !searchQuery.isEmpty {
            let localMatches = try cachedProducts(
                searchQuery: searchQuery,
                category: category,
                sort: sort
            )
            displayProducts = ProductMergePolicy.prependSearchLocalMatches(
                to: displayProducts,
                localMatches: localMatches,
                skip: skip,
                searchQuery: searchQuery
            )
        }

        displayProducts = ProductMergePolicy.deduplicated(displayProducts)
        displayProducts = ProductFiltering.apply(
            to: displayProducts,
            searchQuery: searchQuery,
            category: category,
            sortOption: sort
        )

        let totalCount = ProductMergePolicy.totalCount(
            apiTotal: response.total,
            displayCount: displayProducts.count,
            searchQuery: searchQuery
        )

        return ProductPage(
            products: displayProducts,
            total: totalCount,
            skip: response.skip,
            limit: response.limit
        )
    }

    func fetchProduct(id: Int) async throws -> Product {
        if let local = try localDataSource.record(id: id) {
            let product = ProductMapper.map(local)
            if product.isDeleted {
                throw ProductRepositoryError.productNotFound
            }
            return product
        }

        let dto = try await remoteDataSource.fetchProduct(id: id)
        let product = ProductMapper.map(dto)
        try localDataSource.upsert(product)
        return product
    }

    func saveProduct(_ product: Product) async throws {
        var updated = product
        if updated.id == 0 {
            updated = Product(
                id: try localDataSource.nextLocalID(),
                title: product.title,
                productDescription: product.productDescription,
                price: product.price,
                category: product.category,
                thumbnailURL: product.thumbnailURL,
                imageURLs: product.imageURLs,
                brand: product.brand,
                rating: product.rating,
                stock: product.stock,
                isLocalOnly: true,
                isDeleted: false
            )
        } else {
            updated = Product(
                id: product.id,
                title: product.title,
                productDescription: product.productDescription,
                price: product.price,
                category: product.category,
                thumbnailURL: product.thumbnailURL,
                imageURLs: product.imageURLs,
                brand: product.brand,
                rating: product.rating,
                stock: product.stock,
                isLocalOnly: true,
                isDeleted: false
            )
        }
        try localDataSource.upsert(updated)
    }

    func deleteProduct(id: Int) async throws {
        if try localDataSource.record(id: id) == nil {
            let dto = try await remoteDataSource.fetchProduct(id: id)
            try localDataSource.upsert(ProductMapper.map(dto))
        }
        try localDataSource.deleteRecord(id: id)
    }

    func resetLocalChanges() async throws {
        try localDataSource.resetLocalChanges()
        let dtos = try await remoteDataSource.fetchAllProducts()
        let products = dtos.map { ProductMapper.map($0) }
        try localDataSource.upsertMany(products)
    }

    func categories() throws -> [String] {
        try localDataSource.categories()
    }
}

