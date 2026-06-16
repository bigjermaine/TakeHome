//
//  Created by jermaine daniel on 16/06/2026.
//



import Foundation
import SwiftData

@Model
final class ProductRecord {
    @Attribute(.unique) var id: Int
    var title: String
    var productDescription: String
    var price: Double
    var category: String
    var thumbnailURL: String?
    var imageURLs: [String]
    var brand: String
    var rating: Double
    var stock: Int
    var isLocalOnly: Bool
    var isDeleted: Bool
    var updatedAt: Date

    init(
        id: Int,
        title: String,
        productDescription: String,
        price: Double,
        category: String,
        thumbnailURL: String?,
        imageURLs: [String],
        brand: String,
        rating: Double,
        stock: Int,
        isLocalOnly: Bool,
        isDeleted: Bool,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.productDescription = productDescription
        self.price = price
        self.category = category
        self.thumbnailURL = thumbnailURL
        self.imageURLs = imageURLs
        self.brand = brand
        self.rating = rating
        self.stock = stock
        self.isLocalOnly = isLocalOnly
        self.isDeleted = isDeleted
        self.updatedAt = updatedAt
    }

    func apply(_ product: Product) {
        title = product.title
        productDescription = product.productDescription
        price = product.price
        category = product.category
        thumbnailURL = product.thumbnailURL?.absoluteString
        imageURLs = product.imageURLs.map(\.absoluteString)
        brand = product.brand
        rating = product.rating
        stock = product.stock
        isLocalOnly = product.isLocalOnly
        isDeleted = product.isDeleted
        updatedAt = .now
    }
}

@Model
final class FavoriteRecord {
    @Attribute(.unique) var productID: Int
    var addedAt: Date

    init(productID: Int, addedAt: Date = .now) {
        self.productID = productID
        self.addedAt = addedAt
    }
}
