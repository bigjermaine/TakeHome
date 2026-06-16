//
//  AuthUseCases.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

struct LoginUseCase: Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(credentials: AuthCredentials) async throws -> AuthSession {
        let session = try await authRepository.login(credentials: credentials)
        try authRepository.saveSession(session)
        return session
    }
}

struct ValidateSessionUseCase: Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute() throws -> AuthSession? {
        try authRepository.loadSession()
    }
}

struct LogoutUseCase: Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute() throws {
        try authRepository.clearSession()
    }
}

struct AuthenticateWithBiometricsUseCase: Sendable {
    private let authRepository: AuthRepositoryProtocol
    private let biometricAuth: BiometricAuthProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(
        authRepository: AuthRepositoryProtocol,
        biometricAuth: BiometricAuthProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.biometricAuth = biometricAuth
        self.settingsRepository = settingsRepository
    }

    var canUseBiometrics: Bool {
        authRepository.hasStoredSession() && biometricAuth.canEvaluateBiometrics
    }

    var biometryName: String {
        biometricAuth.biometryName
    }

    func execute() async throws -> AuthSession {
        guard authRepository.hasStoredSession() else {
            throw AuthError.sessionExpired
        }
        guard biometricAuth.canEvaluateBiometrics else {
            throw AuthError.biometricsUnavailable
        }

        let locale = Locale(identifier: settingsRepository.language().localeIdentifier)
        let reason = String(
            localized: String.LocalizationValue("Sign in to your account"),
            locale: locale
        )

        do {
            try await biometricAuth.authenticate(reason: reason)
        } catch {
            throw AuthError.biometricsFailed
        }

        guard let session = try authRepository.loadSession() else {
            throw AuthError.sessionExpired
        }
        return session
    }
}
