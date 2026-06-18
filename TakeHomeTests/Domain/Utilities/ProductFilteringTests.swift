//
//  ProductFilteringTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class ProductFilteringTests: XCTestCase {
    private let sampleProducts: [Product] = [
        Product.fixture(id: 1, title: "Alpha Phone", category: "smartphones", price: 999, brand: "Alpha", rating: 4.5),
        Product.fixture(id: 2, title: "Beta Laptop", category: "laptops", price: 1499, brand: "Beta", rating: 4.8),
        Product.fixture(id: 3, title: "Gamma Phone", category: "smartphones", price: 799, brand: "Gamma", rating: 4.2, stock: 0, isDeleted: true)
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

    func testSort_ordersByTitleAscending() {
        let result = ProductFiltering.sort(
            products: sampleProducts.filter { !$0.isDeleted },
            by: .titleAscending
        )

        XCTAssertEqual(result.map(\.title), ["Alpha Phone", "Beta Laptop"])
    }

    func testSort_ordersByRatingDescending() {
        let result = ProductFiltering.sort(
            products: sampleProducts.filter { !$0.isDeleted },
            by: .ratingDescending
        )

        XCTAssertEqual(result.map(\.id), [2, 1])
    }

    func testApply_matchesBrandInSearchQuery() {
        let result = ProductFiltering.apply(
            to: sampleProducts,
            searchQuery: "beta",
            category: nil,
            sortOption: .titleAscending
        )

        XCTAssertEqual(result.map(\.id), [2])
    }

    func testSort_ordersByPriceAscending() {
        let result = ProductFiltering.sort(
            products: sampleProducts.filter { !$0.isDeleted },
            by: .priceAscending
        )

        XCTAssertEqual(result.map(\.id), [1, 2])
    }

    func testSort_ordersByTitleDescending() {
        let result = ProductFiltering.sort(
            products: sampleProducts.filter { !$0.isDeleted },
            by: .titleDescending
        )

        XCTAssertEqual(result.map(\.title), ["Beta Laptop", "Alpha Phone"])
    }

    func testApply_emptySearchQuery_returnsAllNonDeleted() {
        let result = ProductFiltering.apply(
            to: sampleProducts,
            searchQuery: nil,
            category: "All",
            sortOption: .titleAscending
        )

        XCTAssertEqual(result.map(\.id), [1, 2])
    }
}
