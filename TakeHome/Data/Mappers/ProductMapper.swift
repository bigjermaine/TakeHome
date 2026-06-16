import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let category: String
    let thumbnail: String?
    let images: [String]?
    let brand: String?
    let rating: Double?
    let stock: Int?
}

struct ProductsResponseDTO: Decodable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

struct SingleProductResponseDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let category: String
    let thumbnail: String?
    let images: [String]?
    let brand: String?
    let rating: Double?
    let stock: Int?
}

enum ProductMapper {
    static func map(_ dto: ProductDTO, isLocalOnly: Bool = false, isDeleted: Bool = false) -> Product {
        Product(
            id: dto.id,
            title: dto.title,
            productDescription: dto.description,
            price: dto.price,
            category: dto.category,
            thumbnailURL: dto.thumbnail.flatMap(URL.init(string:)),
            imageURLs: (dto.images ?? []).compactMap(URL.init(string:)),
            brand: dto.brand ?? "",
            rating: dto.rating ?? 0,
            stock: dto.stock ?? 0,
            isLocalOnly: isLocalOnly,
            isDeleted: isDeleted
        )
    }

    static func map(_ dto: SingleProductResponseDTO, isLocalOnly: Bool = false, isDeleted: Bool = false) -> Product {
        map(
            ProductDTO(
                id: dto.id,
                title: dto.title,
                description: dto.description,
                price: dto.price,
                category: dto.category,
                thumbnail: dto.thumbnail,
                images: dto.images,
                brand: dto.brand,
                rating: dto.rating,
                stock: dto.stock
            ),
            isLocalOnly: isLocalOnly,
            isDeleted: isDeleted
        )
    }

    static func map(_ record: ProductRecord) -> Product {
        Product(
            id: record.id,
            title: record.title,
            productDescription: record.productDescription,
            price: record.price,
            category: record.category,
            thumbnailURL: record.thumbnailURL.flatMap(URL.init(string:)),
            imageURLs: record.imageURLs.compactMap(URL.init(string:)),
            brand: record.brand,
            rating: record.rating,
            stock: record.stock,
            isLocalOnly: record.isLocalOnly,
            isDeleted: record.isDeleted
        )
    }
}
