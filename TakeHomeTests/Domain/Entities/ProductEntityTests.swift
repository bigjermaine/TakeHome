//
//  ProductEntityTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class ProductEntityTests: XCTestCase {
    func testIsAvailable_isFalseWhenDeleted() {
        let product = Product.fixture(id: 1, stock: 10, isDeleted: true)

        XCTAssertFalse(product.isAvailable)
    }

    func testIsAvailable_isFalseWhenOutOfStock() {
        let product = Product.fixture(id: 1, stock: 0)

        XCTAssertFalse(product.isAvailable)
    }

    func testIsAvailable_isTrueWhenInStockAndNotDeleted() {
        let product = Product.fixture(id: 1, stock: 3)

        XCTAssertTrue(product.isAvailable)
    }

    func testProductPage_hasMoreWhenAdditionalItemsExist() {
        let page = ProductPage(
            products: [.fixture(id: 1), .fixture(id: 2)],
            total: 50,
            skip: 0,
            limit: 20
        )

        XCTAssertTrue(page.hasMore)
    }

    func testProductPage_hasNoMoreOnFinalPage() {
        let page = ProductPage(
            products: [.fixture(id: 1)],
            total: 1,
            skip: 0,
            limit: 20
        )

        XCTAssertFalse(page.hasMore)
    }
}
