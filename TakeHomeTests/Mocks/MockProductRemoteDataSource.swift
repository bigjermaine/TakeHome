//
//  MockProductRemoteDataSource.swift
//  TakeHomeTests
//

import Foundation
@testable import TakeHome

@MainActor
final class MockProductRemoteDataSource: ProductRemoteDataSourcing {
    var fetchProductsResult = ProductsResponseDTO(products: [], total: 0, skip: 0, limit: 20)
    var searchProductsResult = ProductsResponseDTO(products: [], total: 0, skip: 0, limit: 20)
    var fetchProductResult: SingleProductResponseDTO?
    var fetchAllProductsResult: [ProductDTO] = []
    var fetchProductError: Error?

    func fetchProducts(skip: Int, limit: Int) async throws -> ProductsResponseDTO {
        ProductsResponseDTO(
            products: fetchProductsResult.products,
            total: fetchProductsResult.total,
            skip: skip,
            limit: limit
        )
    }

    func searchProducts(query: String, skip: Int, limit: Int) async throws -> ProductsResponseDTO {
        ProductsResponseDTO(
            products: searchProductsResult.products,
            total: searchProductsResult.total,
            skip: skip,
            limit: limit
        )
    }

    func fetchProduct(id: Int) async throws -> SingleProductResponseDTO {
        if let error = fetchProductError {
            throw error
        }
        guard let result = fetchProductResult else {
            throw URLError(.fileDoesNotExist)
        }
        return result
    }

    func fetchAllProducts() async throws -> [ProductDTO] {
        fetchAllProductsResult
    }
}

extension ProductDTO {
    static func fixture(
        id: Int,
        title: String = "Product",
        category: String = "general",
        price: Double = 10
    ) -> ProductDTO {
        ProductDTO(
            id: id,
            title: title,
            description: "Description",
            price: price,
            category: category,
            thumbnail: nil,
            images: nil,
            brand: "Brand",
            rating: 4,
            stock: 5
        )
    }
}

extension SingleProductResponseDTO {
    static func fixture(
        id: Int,
        title: String = "Product",
        category: String = "general",
        price: Double = 10
    ) -> SingleProductResponseDTO {
        SingleProductResponseDTO(
            id: id,
            title: title,
            description: "Description",
            price: price,
            category: category,
            thumbnail: nil,
            images: nil,
            brand: "Brand",
            rating: 4,
            stock: 5
        )
    }
}
