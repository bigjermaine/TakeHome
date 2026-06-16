import Foundation

protocol ProductRepositoryProtocol: Sendable {
    func fetchProducts(
        skip: Int,
        limit: Int,
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) async throws -> ProductPage

    func fetchProduct(id: Int) async throws -> Product
    func cachedProducts(
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) throws -> [Product]
    func saveProduct(_ product: Product) async throws
    func deleteProduct(id: Int) async throws
    func resetLocalChanges() async throws
    func categories() throws -> [String]
}
