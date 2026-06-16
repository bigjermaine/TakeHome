import Foundation

struct Product: Identifiable, Hashable, Sendable {
    let id: Int
    var title: String
    var productDescription: String
    var price: Double
    var category: String
    var thumbnailURL: URL?
    var imageURLs: [URL]
    var brand: String
    var rating: Double
    var stock: Int
    var isLocalOnly: Bool
    var isDeleted: Bool

    var isAvailable: Bool {
        !isDeleted && stock > 0
    }
}

enum ProductSortOption: String, CaseIterable, Identifiable, Sendable {
    case titleAscending
    case titleDescending
    case priceAscending
    case priceDescending
    case ratingDescending

    var id: String { rawValue }
}

struct ProductPage: Sendable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int

    var hasMore: Bool {
        skip + products.count < total
    }
}
