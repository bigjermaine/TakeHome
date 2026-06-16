//
//  ProductRemoteDataSource.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

struct ProductRemoteDataSource: Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchProducts(skip: Int, limit: Int) async throws -> ProductsResponseDTO {
        try await apiClient.get(
            "products",
            queryItems: [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "skip", value: String(skip))
            ]
        )
    }

    func searchProducts(query: String, skip: Int, limit: Int) async throws -> ProductsResponseDTO {
        try await apiClient.get(
            "products/search",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "skip", value: String(skip))
            ]
        )
    }

    func fetchProduct(id: Int) async throws -> SingleProductResponseDTO {
        try await apiClient.get("products/\(id)")
    }

    func fetchAllProducts() async throws -> [ProductDTO] {
        var allProducts: [ProductDTO] = []
        var skip = 0
        let limit = 100

        while true {
            let response: ProductsResponseDTO = try await fetchProducts(skip: skip, limit: limit)
            allProducts.append(contentsOf: response.products)
            skip += response.products.count
            if skip >= response.total || response.products.isEmpty {
                break
            }
        }

        return allProducts
    }
}
