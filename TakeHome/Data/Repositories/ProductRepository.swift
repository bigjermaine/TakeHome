import Foundation

@MainActor
final class ProductRepository: ProductRepositoryProtocol {
    private let remoteDataSource: ProductRemoteDataSource
    private let localDataSource: ProductLocalDataSource

    init(
        remoteDataSource: ProductRemoteDataSource,
        localDataSource: ProductLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func cachedProducts(
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) throws -> [Product] {
        let products = try localDataSource.allRecords().map(ProductMapper.map)
        return ProductFiltering.apply(
            to: products,
            searchQuery: searchQuery,
            category: category,
            sortOption: sort
        )
    }

    func fetchProducts(
        skip: Int,
        limit: Int,
        searchQuery: String?,
        category: String?,
        sort: ProductSortOption
    ) async throws -> ProductPage {
        let response: ProductsResponseDTO
        if let searchQuery, !searchQuery.isEmpty {
            response = try await remoteDataSource.searchProducts(
                query: searchQuery,
                skip: skip,
                limit: limit
            )
        } else {
            response = try await remoteDataSource.fetchProducts(skip: skip, limit: limit)
        }

        let remoteProducts = response.products.map { ProductMapper.map($0) }
        try localDataSource.upsertMany(remoteProducts)

        var displayProducts = remoteProducts.compactMap { remote -> Product? in
            if let local = try? localDataSource.record(id: remote.id) {
                let mapped = ProductMapper.map(local)
                return mapped.isDeleted ? nil : mapped
            }
            return remote
        }

        if skip == 0 {
            let apiIDs = Set(displayProducts.map(\.id))
            let createdLocally = try localDataSource.allRecords()
                .filter { $0.isLocalOnly && !$0.isDeleted && $0.id < 0 && !apiIDs.contains($0.id) }
                .map(ProductMapper.map)
            displayProducts = createdLocally + displayProducts

            if let searchQuery, !searchQuery.isEmpty {
                let localMatches = try cachedProducts(
                    searchQuery: searchQuery,
                    category: category,
                    sort: sort
                )
                let mergedIDs = Set(displayProducts.map(\.id))
                let additionalMatches = localMatches.filter { !mergedIDs.contains($0.id) }
                displayProducts = additionalMatches + displayProducts
            }
        }

        displayProducts = deduplicated(displayProducts)
        displayProducts = ProductFiltering.apply(
            to: displayProducts,
            searchQuery: searchQuery,
            category: category,
            sortOption: sort
        )

        let totalCount: Int
        if let searchQuery, !searchQuery.isEmpty {
            totalCount = max(response.total, displayProducts.count)
        } else {
            totalCount = response.total
        }

        return ProductPage(
            products: displayProducts,
            total: totalCount,
            skip: response.skip,
            limit: response.limit
        )
    }

    func fetchProduct(id: Int) async throws -> Product {
        if let local = try localDataSource.record(id: id) {
            return ProductMapper.map(local)
        }

        let dto = try await remoteDataSource.fetchProduct(id: id)
        let product = ProductMapper.map(dto)
        try localDataSource.upsert(product)
        return product
    }

    func saveProduct(_ product: Product) async throws {
        var updated = product
        if updated.id == 0 {
            updated = Product(
                id: try localDataSource.nextLocalID(),
                title: product.title,
                productDescription: product.productDescription,
                price: product.price,
                category: product.category,
                thumbnailURL: product.thumbnailURL,
                imageURLs: product.imageURLs,
                brand: product.brand,
                rating: product.rating,
                stock: product.stock,
                isLocalOnly: true,
                isDeleted: false
            )
        } else {
            updated = Product(
                id: product.id,
                title: product.title,
                productDescription: product.productDescription,
                price: product.price,
                category: product.category,
                thumbnailURL: product.thumbnailURL,
                imageURLs: product.imageURLs,
                brand: product.brand,
                rating: product.rating,
                stock: product.stock,
                isLocalOnly: true,
                isDeleted: false
            )
        }
        try localDataSource.upsert(updated)
    }

    func deleteProduct(id: Int) async throws {
        try localDataSource.deleteRecord(id: id)
    }

    func resetLocalChanges() async throws {
        try localDataSource.resetLocalChanges()
        let dtos = try await remoteDataSource.fetchAllProducts()
        let products = dtos.map { ProductMapper.map($0) }
        try localDataSource.upsertMany(products)
    }

    func categories() throws -> [String] {
        try localDataSource.categories()
    }

    private func deduplicated(_ products: [Product]) -> [Product] {
        var seen = Set<Int>()
        return products.filter { product in
            guard seen.insert(product.id).inserted else { return false }
            return true
        }
    }
}

