//
//  AuthModule.swift
//  TakeHome
//

import Foundation

@MainActor
final class AuthModule {
    let loginUseCase: LoginUseCase
    let validateSessionUseCase: ValidateSessionUseCase
    let logoutUseCase: LogoutUseCase
    let biometricLoginUseCase: AuthenticateWithBiometricsUseCase

    private let biometricAuth: BiometricAuthProtocol
    private lazy var loginViewModel = LoginViewModel(
        loginUseCase: loginUseCase,
        biometricLoginUseCase: biometricLoginUseCase,
        router: router
    )

    private unowned let router: AppRouter

    var isBiometricAuthAvailable: Bool {
        biometricAuth.canEvaluateBiometrics
    }

    init(router: AppRouter, settingsRepository: SettingsRepositoryProtocol) {
        self.router = router

        let keychain = KeychainService()
        let authRepository: AuthRepositoryProtocol = AuthRepository(keychain: keychain)
        biometricAuth = BiometricAuthenticator()

        loginUseCase = LoginUseCase(authRepository: authRepository)
        validateSessionUseCase = ValidateSessionUseCase(authRepository: authRepository)
        logoutUseCase = LogoutUseCase(authRepository: authRepository)
        biometricLoginUseCase = AuthenticateWithBiometricsUseCase(
            authRepository: authRepository,
            biometricAuth: biometricAuth,
            settingsRepository: settingsRepository
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        loginViewModel
    }
}
