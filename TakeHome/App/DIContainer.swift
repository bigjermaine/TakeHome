//
//  DIContainer.swift
//  TakeHome
//

import SwiftUI
import SwiftData

@MainActor
final class DIContainer: AppRouterDependencyProviding {
    let infrastructure: AppInfrastructure
    let settings: SettingsModule

    private(set) lazy var appRouter = AppRouter(dependencies: self)
    private(set) lazy var auth = AuthModule(
        router: appRouter,
        settingsRepository: settings.settingsRepository
    )
    private(set) lazy var favorites = FavoritesModule(
        infrastructure: infrastructure,
        router: appRouter
    )
    private(set) lazy var products = ProductModule(
        infrastructure: infrastructure,
        toggleFavoriteUseCase: favorites.toggleFavoriteUseCase,
        fetchFavoritesUseCase: favorites.fetchFavoritesUseCase,
        router: appRouter
    )

    var modelContainer: ModelContainer { infrastructure.modelContainer }
    var networkMonitor: NetworkMonitor { infrastructure.networkMonitor }
    var appPreferencesStore: AppPreferencesStore { settings.appPreferencesStore }

    var isBiometricAuthAvailable: Bool { auth.isBiometricAuthAvailable }
    var deleteProductUseCase: DeleteProductUseCase { products.deleteProductUseCase }
    var validateSessionUseCase: ValidateSessionUseCase { auth.validateSessionUseCase }
    var loadSettingsUseCase: LoadSettingsUseCase { settings.loadSettingsUseCase }
    var logoutUseCase: LogoutUseCase { auth.logoutUseCase }

    init() {
        infrastructure = AppInfrastructure()
        settings = SettingsModule()
    }

    func makeLoginViewModel() -> LoginViewModel {
        auth.makeLoginViewModel()
    }

    func makeProductListViewModel() -> ProductListViewModel {
        products.makeProductListViewModel()
    }

    func makeProductDetailViewModel(productID: Int) -> ProductDetailViewModel {
        products.makeProductDetailViewModel(productID: productID)
    }

    func makeProductEditorViewModel(productID: Int?) -> ProductEditorViewModel {
        products.makeProductEditorViewModel(productID: productID)
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        favorites.makeFavoritesViewModel()
    }

    func invalidateProductDetailViewModel(productID: Int) {
        products.invalidateProductDetailViewModel(productID: productID)
    }
}
