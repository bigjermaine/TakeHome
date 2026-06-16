//
//  Product+Fixture.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
@testable import TakeHome

extension Product {
    static func fixture(
        id: Int,
        title: String = "Product",
        category: String = "general",
        price: Double = 10,
        brand: String = "Brand",
        rating: Double = 4.0,
        stock: Int = 5,
        isLocalOnly: Bool = false,
        isDeleted: Bool = false
    ) -> Product {
        Product(
            id: id,
            title: title,
            productDescription: "Description",
            price: price,
            category: category,
            thumbnailURL: nil,
            imageURLs: [],
            brand: brand,
            rating: rating,
            stock: stock,
            isLocalOnly: isLocalOnly,
            isDeleted: isDeleted
        )
    }
}
