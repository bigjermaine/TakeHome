import Foundation

struct FetchFavoritesUseCase: Sendable {
    private let favoritesRepository: FavoritesRepositoryProtocol

    init(favoritesRepository: FavoritesRepositoryProtocol) {
        self.favoritesRepository = favoritesRepository
    }

    func execute() throws -> [Product] {
        try favoritesRepository.fetchFavorites()
    }
}

struct ToggleFavoriteUseCase: Sendable {
    private let favoritesRepository: FavoritesRepositoryProtocol

    init(favoritesRepository: FavoritesRepositoryProtocol) {
        self.favoritesRepository = favoritesRepository
    }

    func isFavorite(productID: Int) throws -> Bool {
        try favoritesRepository.isFavorite(productID: productID)
    }

    func add(productID: Int) throws {
        try favoritesRepository.addFavorite(productID: productID)
    }

    func remove(productID: Int) throws -> Product? {
        try favoritesRepository.removeFavorite(productID: productID)
    }
}
