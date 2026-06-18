//
//  ProductMapperTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class ProductMapperTests: XCTestCase {
    func testMap_dto_appliesDefaultsForMissingFields() {
        let dto = ProductDTO(
            id: 1,
            title: "Phone",
            description: "A phone",
            price: 499.99,
            category: "smartphones",
            thumbnail: nil,
            images: nil,
            brand: nil,
            rating: nil,
            stock: nil
        )

        let product = ProductMapper.map(dto)

        XCTAssertEqual(product.id, 1)
        XCTAssertEqual(product.title, "Phone")
        XCTAssertEqual(product.brand, "")
        XCTAssertEqual(product.rating, 0)
        XCTAssertEqual(product.stock, 0)
        XCTAssertFalse(product.isLocalOnly)
        XCTAssertFalse(product.isDeleted)
    }

    func testMap_dto_parsesURLs() {
        let dto = ProductDTO(
            id: 2,
            title: "Laptop",
            description: "A laptop",
            price: 999,
            category: "laptops",
            thumbnail: "https://example.com/thumb.jpg",
            images: ["https://example.com/1.jpg", "https://example.com/2.jpg"],
            brand: "Brand",
            rating: 4.5,
            stock: 10
        )

        let product = ProductMapper.map(dto)

        XCTAssertEqual(product.thumbnailURL?.absoluteString, "https://example.com/thumb.jpg")
        XCTAssertEqual(product.imageURLs.count, 2)
        XCTAssertEqual(product.brand, "Brand")
        XCTAssertEqual(product.rating, 4.5)
        XCTAssertEqual(product.stock, 10)
    }

    func testMap_record_preservesLocalFlags() {
        let record = ProductRecord(
            id: -1,
            title: "Local",
            productDescription: "Desc",
            price: 12,
            category: "custom",
            thumbnailURL: nil,
            imageURLs: [],
            brand: "Mine",
            rating: 3,
            stock: 1,
            isLocalOnly: true,
            isDeleted: true
        )

        let product = ProductMapper.map(record)

        XCTAssertEqual(product.id, -1)
        XCTAssertTrue(product.isLocalOnly)
        XCTAssertTrue(product.isDeleted)
        XCTAssertEqual(product.title, "Local")
    }
}
