//
//  ProductModule.swift
//  TakeHome
//

import Foundation
import SwiftData

@MainActor
final class ProductModule {
    let fetchProductsUseCase: FetchProductsUseCase
    let fetchProductDetailUseCase: FetchProductDetailUseCase
    let saveProductUseCase: SaveProductUseCase
    let deleteProductUseCase: DeleteProductUseCase
    let resetProductsUseCase: ResetProductsUseCase
    let fetchCategoriesUseCase: FetchCategoriesUseCase

    private let imageLoader: ImageLoadingProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private unowned let router: AppRouter

    private lazy var productListViewModel = ProductListViewModel(
        fetchProductsUseCase: fetchProductsUseCase,
        fetchCategoriesUseCase: fetchCategoriesUseCase,
        fetchFavoritesUseCase: fetchFavoritesUseCase,
        toggleFavoriteUseCase: toggleFavoriteUseCase,
        resetProductsUseCase: resetProductsUseCase,
        router: router
    )

    private var detailViewModelCache: [Int: ProductDetailViewModel] = [:]
    private var editorViewModelCache: [String: ProductEditorViewModel] = [:]

    private let fetchFavoritesUseCase: FetchFavoritesUseCase

    init(
        infrastructure: AppInfrastructure,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        fetchFavoritesUseCase: FetchFavoritesUseCase,
        router: AppRouter
    ) {
        self.router = router
        self.imageLoader = infrastructure.imageLoader
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.fetchFavoritesUseCase = fetchFavoritesUseCase

        let apiClient = APIClient()
        let productRemoteDataSource = ProductRemoteDataSource(apiClient: apiClient)
        let productLocalDataSource = ProductLocalDataSource(
            modelContext: infrastructure.modelContainer.mainContext
        )
        let productRepository: ProductRepositoryProtocol = ProductRepository(
            remoteDataSource: productRemoteDataSource,
            localDataSource: productLocalDataSource
        )

        fetchProductsUseCase = FetchProductsUseCase(productRepository: productRepository)
        fetchProductDetailUseCase = FetchProductDetailUseCase(productRepository: productRepository)
        saveProductUseCase = SaveProductUseCase(productRepository: productRepository)
        deleteProductUseCase = DeleteProductUseCase(productRepository: productRepository)
        resetProductsUseCase = ResetProductsUseCase(productRepository: productRepository)
        fetchCategoriesUseCase = FetchCategoriesUseCase(productRepository: productRepository)
    }

    func makeProductListViewModel() -> ProductListViewModel {
        productListViewModel
    }

    func makeProductDetailViewModel(productID: Int) -> ProductDetailViewModel {
        if let cached = detailViewModelCache[productID] {
            return cached
        }

        let viewModel = ProductDetailViewModel(
            productID: productID,
            fetchProductDetailUseCase: fetchProductDetailUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            imageLoader: imageLoader,
            router: router
        )
        detailViewModelCache[productID] = viewModel
        return viewModel
    }

    func makeProductEditorViewModel(productID: Int?) -> ProductEditorViewModel {
        let cacheKey = productID.map(String.init) ?? "new"
        if let cached = editorViewModelCache[cacheKey] {
            return cached
        }

        let viewModel = ProductEditorViewModel(
            productID: productID,
            fetchProductDetailUseCase: fetchProductDetailUseCase,
            saveProductUseCase: saveProductUseCase,
            router: router
        )
        editorViewModelCache[cacheKey] = viewModel
        return viewModel
    }

    func invalidateProductDetailViewModel(productID: Int) {
        detailViewModelCache.removeValue(forKey: productID)
    }
}
