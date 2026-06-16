//
//  AppRouter.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
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

    private let container: DIContainer
    private var needsUnlockAfterBackground = false
    private var activeDetailPath: TabRoute?

    init(container: DIContainer) {
        self.container = container
    }

    var isBiometricAuthAvailable: Bool {
        container.isBiometricAuthAvailable
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
            try await container.deleteProductUseCase.execute(id: productID)
            popProductDetail(for: productID)
            HapticFeedback.play(.success)
        } catch {
            container.makeProductDetailViewModel(productID: productID).showError(error.localizedDescription)
            HapticFeedback.play(.error)
        }
    }

    func popProductDetail(for productID: Int) {
        container.invalidateProductDetailViewModel(productID: productID)

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
        container.makeProductListViewModel().reloadFromCache()
        refreshFavorites()
    }

    func handleUnlikeFromDetail() {
        if selectedTab == .favorites && !favoritesPath.isEmpty {
            favoritesPath.removeLast()
        }
        refreshFavorites()
    }

    func refreshFavorites() {
        container.makeFavoritesViewModel().load()
    }

    func logout() async {
        try? container.logoutUseCase.execute()
        showLogin()
    }

    private var hasStoredSession: Bool {
        (try? container.validateSessionUseCase.execute()) != nil
    }

    private func shouldRequireBiometricUnlock() -> Bool {
        container.loadSettingsUseCase.requireBiometricsOnLaunch()
    }

    private func presentSignIn() {
        loginMode = .signIn
        appRoute = .login
        container.makeLoginViewModel().prepareForPresentation(mode: .signIn)
    }

    private func presentUnlock() {
        loginMode = .unlock
        appRoute = .login
        container.makeLoginViewModel().prepareForPresentation(mode: .unlock)
    }
}
