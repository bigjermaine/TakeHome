//
//  AppRouterDependencies.swift
//  TakeHome
//

import Foundation

@MainActor
protocol AppRouterDependencyProviding: AnyObject {
    var isBiometricAuthAvailable: Bool { get }
    var deleteProductUseCase: DeleteProductUseCase { get }
    var validateSessionUseCase: ValidateSessionUseCase { get }
    var loadSettingsUseCase: LoadSettingsUseCase { get }
    var logoutUseCase: LogoutUseCase { get }

    func makeLoginViewModel() -> LoginViewModel
    func makeProductDetailViewModel(productID: Int) -> ProductDetailViewModel
    func makeProductListViewModel() -> ProductListViewModel
    func makeFavoritesViewModel() -> FavoritesViewModel
    func invalidateProductDetailViewModel(productID: Int)
}
