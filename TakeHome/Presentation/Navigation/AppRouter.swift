//
//  AppRouter.swift
//  TakeHome
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var appRoute: AppRoute = .login
    @Published var loginMode: LoginMode = .signIn
    @Published var selectedTab: TabRoute = .products
    @Published var productPath = NavigationPath()
    @Published var favoritesPath = NavigationPath()
    @Published var isDeleteConfirmationPresented = false
    @Published var deleteConfirmationProductID: Int?
    @Published var deleteConfirmationIsLocalOnly = false

    private let dependencies: AppRouterDependencyProviding
    private var needsUnlockAfterBackground = false
    private var activeDetailPath: TabRoute?

    init(dependencies: AppRouterDependencyProviding) {
        self.dependencies = dependencies
    }

    var isBiometricAuthAvailable: Bool {
        dependencies.isBiometricAuthAvailable
    }

    func bootstrap() async {
        guard hasStoredSession else {
            presentSignIn()
            return
        }

        if shouldRequireBiometricUnlock() {
            presentUnlock()
        } else {
            showMain()
        }
    }

    func lockAppIfNeeded() {
        guard needsUnlockAfterBackground else { return }
        needsUnlockAfterBackground = false
        guard hasStoredSession else { return }
        guard shouldRequireBiometricUnlock() else { return }
        presentUnlock()
    }

    func prepareForBackgroundLock() {
        guard appRoute == .main else { return }
        guard hasStoredSession else { return }
        guard shouldRequireBiometricUnlock() else { return }
        needsUnlockAfterBackground = true
    }

    func showLogin() {
        productPath = NavigationPath()
        favoritesPath = NavigationPath()
        presentSignIn()
    }

    func showMain() {
        appRoute = .main
        needsUnlockAfterBackground = false
    }

    func openProductDetail(id: Int) {
        selectedTab = .products
        activeDetailPath = .products
        productPath.append(ProductRoute.detail(productID: id))
    }

    func openFavoriteProductDetail(id: Int) {
        selectedTab = .favorites
        activeDetailPath = .favorites
        favoritesPath.append(ProductRoute.detail(productID: id))
    }

    func openProductEditor(id: Int?) {
        selectedTab = .products
        productPath.append(ProductRoute.editor(productID: id))
    }

    func presentDeleteConfirmation(for productID: Int, isLocalOnly: Bool) {
        deleteConfirmationProductID = productID
        deleteConfirmationIsLocalOnly = isLocalOnly
        isDeleteConfirmationPresented = true
    }

    func dismissDeleteConfirmation() {
        deleteConfirmationProductID = nil
        deleteConfirmationIsLocalOnly = false
        isDeleteConfirmationPresented = false
    }

    func confirmDeleteProduct(productID: Int) async {
        do {
            try await dependencies.deleteProductUseCase.execute(id: productID)
            popProductDetail(for: productID)
            HapticFeedback.play(.success)
        } catch {
            dependencies.makeProductDetailViewModel(productID: productID).showError(error.localizedDescription)
            HapticFeedback.play(.error)
        }
    }

    func popProductDetail(for productID: Int) {
        dependencies.invalidateProductDetailViewModel(productID: productID)

        switch activeDetailPath {
        case .favorites:
            if !favoritesPath.isEmpty {
                favoritesPath.removeLast()
            }
        case .products, .settings, .none:
            if !productPath.isEmpty {
                productPath.removeLast()
            }
        }

        activeDetailPath = nil
        dependencies.makeProductListViewModel().reloadFromCache()
        refreshFavorites()
    }

    func handleUnlikeFromDetail() {
        if selectedTab == .favorites && !favoritesPath.isEmpty {
            favoritesPath.removeLast()
        }
        refreshFavorites()
    }

    func refreshFavorites() {
        dependencies.makeFavoritesViewModel().load()
    }

    func logout() async {
        try? dependencies.logoutUseCase.execute()
        showLogin()
    }

    private var hasStoredSession: Bool {
        (try? dependencies.validateSessionUseCase.execute()) != nil
    }

    private func shouldRequireBiometricUnlock() -> Bool {
        dependencies.loadSettingsUseCase.requireBiometricsOnLaunch()
    }

    private func presentSignIn() {
        loginMode = .signIn
        appRoute = .login
        dependencies.makeLoginViewModel().prepareForPresentation(mode: .signIn)
    }

    private func presentUnlock() {
        loginMode = .unlock
        appRoute = .login
        dependencies.makeLoginViewModel().prepareForPresentation(mode: .unlock)
    }
}
