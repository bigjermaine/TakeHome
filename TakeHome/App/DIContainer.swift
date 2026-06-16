//
//  DIContainer.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI
import SwiftData
import Nuke

@MainActor
final class DIContainer {
    let modelContainer: ModelContainer
    let imagePipeline: ImagePipeline
    let imageLoader: ImageLoadingProtocol

    private(set) lazy var appRouter = AppRouter(container: self)
    private(set) lazy var networkMonitor = NetworkMonitor()

    private lazy var keychain = KeychainService()
    private lazy var apiClient = APIClient()
    private lazy var biometricAuth: BiometricAuthProtocol = BiometricAuthenticator()

    private lazy var authRepository: AuthRepositoryProtocol = AuthRepository(keychain: keychain)
    private lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepository()

    private lazy var productRemoteDataSource = ProductRemoteDataSource(apiClient: apiClient)

    private lazy var productLocalDataSource = ProductLocalDataSource(
        modelContext: modelContainer.mainContext
    )
    private lazy var favoritesLocalDataSource = FavoritesLocalDataSource(
        modelContext: modelContainer.mainContext
    )

    private lazy var productRepository: ProductRepositoryProtocol = ProductRepository(
        remoteDataSource: productRemoteDataSource,
        localDataSource: productLocalDataSource
    )
    private lazy var favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository(
        favoritesLocalDataSource: favoritesLocalDataSource,
        productLocalDataSource: productLocalDataSource
    )

    lazy var loginUseCase = LoginUseCase(authRepository: authRepository)
    lazy var validateSessionUseCase = ValidateSessionUseCase(authRepository: authRepository)
    lazy var logoutUseCase = LogoutUseCase(authRepository: authRepository)
    lazy var biometricLoginUseCase = AuthenticateWithBiometricsUseCase(
        authRepository: authRepository,
        biometricAuth: biometricAuth,
        settingsRepository: settingsRepository
    )

    lazy var fetchProductsUseCase = FetchProductsUseCase(productRepository: productRepository)
    lazy var fetchProductDetailUseCase = FetchProductDetailUseCase(productRepository: productRepository)
    lazy var saveProductUseCase = SaveProductUseCase(productRepository: productRepository)
    lazy var resetProductsUseCase = ResetProductsUseCase(productRepository: productRepository)
    lazy var fetchCategoriesUseCase = FetchCategoriesUseCase(productRepository: productRepository)

    lazy var fetchFavoritesUseCase = FetchFavoritesUseCase(favoritesRepository: favoritesRepository)
    lazy var toggleFavoriteUseCase = ToggleFavoriteUseCase(favoritesRepository: favoritesRepository)

    lazy var loadSettingsUseCase = LoadSettingsUseCase(settingsRepository: settingsRepository)
    lazy var updateSettingsUseCase = UpdateSettingsUseCase(settingsRepository: settingsRepository)

    var isBiometricAuthAvailable: Bool {
        biometricAuth.canEvaluateBiometrics
    }

    private(set) lazy var appPreferencesStore = AppPreferencesStore(
        loadSettingsUseCase: loadSettingsUseCase,
        updateSettingsUseCase: updateSettingsUseCase
    )

    private var detailViewModelCache: [Int: ProductDetailViewModel] = [:]
    private var editorViewModelCache: [String: ProductEditorViewModel] = [:]
    private lazy var productListViewModel = ProductListViewModel(
        fetchProductsUseCase: fetchProductsUseCase,
        fetchCategoriesUseCase: fetchCategoriesUseCase,
        fetchFavoritesUseCase: fetchFavoritesUseCase,
        toggleFavoriteUseCase: toggleFavoriteUseCase,
        resetProductsUseCase: resetProductsUseCase,
        router: appRouter
    )
    private lazy var favoritesViewModel = FavoritesViewModel(
        fetchFavoritesUseCase: fetchFavoritesUseCase,
        toggleFavoriteUseCase: toggleFavoriteUseCase,
        router: appRouter
    )
    private lazy var loginViewModel = LoginViewModel(
        loginUseCase: loginUseCase,
        biometricLoginUseCase: biometricLoginUseCase,
        router: appRouter
    )

    init() {
        imagePipeline = ImagePipelineFactory.makeShared()
        ImagePipeline.shared = imagePipeline
        imageLoader = NukeImageLoader(pipeline: imagePipeline)

        do {
            modelContainer = try ModelContainer(
                for: ProductRecord.self, FavoriteRecord.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    func makeLoginViewModel() -> LoginViewModel {
        loginViewModel
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
            router: appRouter
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
            router: appRouter
        )
        editorViewModelCache[cacheKey] = viewModel
        return viewModel
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        favoritesViewModel
    }
}
