import Foundation

protocol FavoritesRepositoryProtocol: Sendable {
    func fetchFavorites() throws -> [Product]
    func isFavorite(productID: Int) throws -> Bool
    func addFavorite(productID: Int) throws
    func removeFavorite(productID: Int) throws -> Product?
}
