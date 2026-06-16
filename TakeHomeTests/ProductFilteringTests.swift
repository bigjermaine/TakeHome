//
//  ProductFilteringTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

final class ProductFilteringTests: XCTestCase {
    private let sampleProducts: [Product] = [
        Product(
            id: 1,
            title: "Alpha Phone",
            productDescription: "A phone",
            price: 999,
            category: "smartphones",
            thumbnailURL: nil,
            imageURLs: [],
            brand: "Alpha",
            rating: 4.5,
            stock: 10,
            isLocalOnly: false,
            isDeleted: false
        ),
        Product(
            id: 2,
            title: "Beta Laptop",
            productDescription: "A laptop",
            price: 1499,
            category: "laptops",
            thumbnailURL: nil,
            imageURLs: [],
            brand: "Beta",
            rating: 4.8,
            stock: 5,
            isLocalOnly: false,
            isDeleted: false
        ),
        Product(
            id: 3,
            title: "Gamma Phone",
            productDescription: "Another phone",
            price: 799,
            category: "smartphones",
            thumbnailURL: nil,
            imageURLs: [],
            brand: "Gamma",
            rating: 4.2,
            stock: 0,
            isLocalOnly: false,
            isDeleted: true
        )
    ]

    func testApply_filtersDeletedProducts() {
        let result = ProductFiltering.apply(
            to: sampleProducts,
            searchQuery: nil,
            category: nil,
            sortOption: .titleAscending
        )

        XCTAssertEqual(result.map(\.id), [1, 2])
    }

    func testApply_filtersByCategory() {
        let result = ProductFiltering.apply(
            to: sampleProducts,
            searchQuery: nil,
            category: "smartphones",
            sortOption: .titleAscending
        )

        XCTAssertEqual(result.map(\.title), ["Alpha Phone"])
    }

    func testApply_filtersBySearchQuery() {
        let result = ProductFiltering.apply(
            to: sampleProducts,
            searchQuery: "laptop",
            category: nil,
            sortOption: .titleAscending
        )

        XCTAssertEqual(result.map(\.id), [2])
    }

    func testSort_ordersByPriceDescending() {
        let result = ProductFiltering.sort(
            products: sampleProducts.filter { !$0.isDeleted },
            by: .priceDescending
        )

        XCTAssertEqual(result.map(\.id), [2, 1])
    }
}
