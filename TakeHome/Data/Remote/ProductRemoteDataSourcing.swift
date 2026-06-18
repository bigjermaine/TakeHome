//
//  ProductRemoteDataSourcing.swift
//  TakeHome
//

import Foundation

@MainActor
protocol ProductRemoteDataSourcing {
    func fetchProducts(skip: Int, limit: Int) async throws -> ProductsResponseDTO
    func searchProducts(query: String, skip: Int, limit: Int) async throws -> ProductsResponseDTO
    func fetchProduct(id: Int) async throws -> SingleProductResponseDTO
    func fetchAllProducts() async throws -> [ProductDTO]
}

extension ProductRemoteDataSource: ProductRemoteDataSourcing {}
