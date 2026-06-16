//
//  TestMocks.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
@testable import TakeHome

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    var loginResult: Result<AuthSession, Error> = .success(
        AuthSession(username: "demo", token: "token", createdAt: .now)
    )
    var storedSession: AuthSession?
    var saveSessionCalled = false
    var clearSessionCalled = false

    func login(credentials: AuthCredentials) async throws -> AuthSession {
        try loginResult.get()
    }

    func saveSession(_ session: AuthSession) throws {
        saveSessionCalled = true
        storedSession = session
    }

    func loadSession() throws -> AuthSession? {
        storedSession
    }

    func clearSession() throws {
        clearSessionCalled = true
        storedSession = nil
    }

    func hasStoredSession() -> Bool {
        storedSession != nil
    }
}

final class MockBiometricAuth: BiometricAuthProtocol, @unchecked Sendable {
    var canEvaluateBiometrics = true
    var biometryName = "Face ID"
    var authenticateResult: Result<Void, Error> = .success(())

    func authenticate(reason: String) async throws {
        try authenticateResult.get()
    }
}

final class MockSettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    func language() -> AppLanguage {
        .english
    }

    func theme() -> AppTheme {
        .system
    }

    func setLanguage(_ language: AppLanguage) {}

    func setTheme(_ theme: AppTheme) {}

    func hapticsEnabled() -> Bool { true }

    func setHapticsEnabled(_ enabled: Bool) {}

    func requireBiometricsOnLaunch() -> Bool { true }

    func setRequireBiometricsOnLaunch(_ required: Bool) {}
}

final class InMemoryKeychain: @unchecked Sendable {
    private var storage: [String: Data] = [:]

    func save(_ data: Data, account: String) throws {
        storage[account] = data
    }

    func read(account: String) throws -> Data? {
        storage[account]
    }

    func delete(account: String) throws {
        storage.removeValue(forKey: account)
    }
}
