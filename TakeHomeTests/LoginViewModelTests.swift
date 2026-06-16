//
//  LoginViewModelTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class LoginViewModelTests: XCTestCase {
    private func makeViewModel(
        authRepository: MockAuthRepository = MockAuthRepository(),
        biometrics: MockBiometricAuth = MockBiometricAuth(),
        settings: MockSettingsRepository = MockSettingsRepository()
    ) -> (LoginViewModel, DIContainer) {
        let container = DIContainer()
        let loginUseCase = LoginUseCase(authRepository: authRepository)
        let biometricUseCase = AuthenticateWithBiometricsUseCase(
            authRepository: authRepository,
            biometricAuth: biometrics,
            settingsRepository: settings
        )
        let viewModel = LoginViewModel(
            loginUseCase: loginUseCase,
            biometricLoginUseCase: biometricUseCase,
            router: container.appRouter
        )
        return (viewModel, container)
    }

    func testIsLoginEnabled_requiresUsernamePasswordAndNotLoading() {
        let (viewModel, _) = makeViewModel()

        viewModel.username = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.isLoginEnabled)

        viewModel.username = "demo"
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.isLoginEnabled)
    }

    func testLogin_emptyUsername_setsValidationError() async {
        let (viewModel, container) = makeViewModel()
        viewModel.username = "   "
        viewModel.password = "password123"

        await viewModel.login()

        XCTAssertEqual(viewModel.viewState, .error("Username is required."))
        XCTAssertEqual(container.appRouter.appRoute, .login)
    }

    func testLogin_emptyPassword_setsValidationError() async {
        let (viewModel, container) = makeViewModel()
        viewModel.username = "demo"
        viewModel.password = ""

        await viewModel.login()

        XCTAssertEqual(viewModel.viewState, .error("Password is required."))
        XCTAssertEqual(container.appRouter.appRoute, .login)
    }

    func testLogin_success_navigatesToMain() async {
        let (viewModel, container) = makeViewModel()
        viewModel.username = "demo"
        viewModel.password = "password123"

        await viewModel.login()

        XCTAssertEqual(viewModel.viewState, .idle)
        XCTAssertEqual(container.appRouter.appRoute, .main)
    }

    func testLogin_invalidCredentials_setsErrorState() async {
        let repository = MockAuthRepository()
        repository.loginResult = .failure(AuthError.invalidCredentials)
        let (viewModel, container) = makeViewModel(authRepository: repository)
        viewModel.username = "bad"
        viewModel.password = "bad"

        await viewModel.login()

        XCTAssertEqual(viewModel.viewState, .error(AuthError.invalidCredentials.localizationKey))
        XCTAssertEqual(container.appRouter.appRoute, .login)
    }

    func testPrepareForPresentation_signIn_clearsFields() {
        let (viewModel, _) = makeViewModel()
        viewModel.username = "demo"
        viewModel.password = "password123"

        viewModel.prepareForPresentation(mode: .signIn)

        XCTAssertEqual(viewModel.username, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertEqual(viewModel.loginMode, .signIn)
        XCTAssertEqual(viewModel.viewState, .idle)
    }

    func testBiometrySystemImage_matchesBiometryName() {
        let biometrics = MockBiometricAuth()
        biometrics.biometryName = "Face ID"
        let (viewModel, _) = makeViewModel(biometrics: biometrics)

        viewModel.refreshBiometricAvailability()

        XCTAssertEqual(viewModel.biometrySystemImage, "faceid")

        biometrics.biometryName = "Touch ID"
        viewModel.refreshBiometricAvailability()
        XCTAssertEqual(viewModel.biometrySystemImage, "touchid")
    }
}
