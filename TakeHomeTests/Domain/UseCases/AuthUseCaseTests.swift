//
//  AuthUseCaseTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class LoginUseCaseTests: XCTestCase {
    func testExecute_savesSessionOnSuccess() async throws {
        let repository = MockAuthRepository()
        let useCase = LoginUseCase(authRepository: repository)

        let session = try await useCase.execute(
            credentials: AuthCredentials(username: "demo", password: "password123")
        )

        XCTAssertEqual(session.username, "demo")
        XCTAssertTrue(repository.saveSessionCalled)
        XCTAssertEqual(repository.storedSession?.username, "demo")
    }

    func testExecute_propagatesInvalidCredentials() async {
        let repository = MockAuthRepository()
        repository.loginResult = .failure(AuthError.invalidCredentials)
        let useCase = LoginUseCase(authRepository: repository)

        do {
            _ = try await useCase.execute(
                credentials: AuthCredentials(username: "bad", password: "bad")
            )
            XCTFail("Expected invalid credentials")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

@MainActor
final class ValidateSessionUseCaseTests: XCTestCase {
    func testExecute_returnsStoredSession() throws {
        let repository = MockAuthRepository()
        repository.storedSession = AuthSession(username: "demo", token: "abc", createdAt: .now)
        let useCase = ValidateSessionUseCase(authRepository: repository)

        let session = try useCase.execute()

        XCTAssertEqual(session?.username, "demo")
    }

    func testLogout_clearsSession() throws {
        let repository = MockAuthRepository()
        repository.storedSession = AuthSession(username: "demo", token: "abc", createdAt: .now)
        let useCase = LogoutUseCase(authRepository: repository)

        try useCase.execute()

        XCTAssertTrue(repository.clearSessionCalled)
        XCTAssertNil(repository.storedSession)
    }
}

@MainActor
final class BiometricLoginUseCaseTests: XCTestCase {
    func testExecute_requiresStoredSession() async {
        let repository = MockAuthRepository()
        let biometrics = MockBiometricAuth()
        let settings = MockSettingsRepository()
        let useCase = AuthenticateWithBiometricsUseCase(
            authRepository: repository,
            biometricAuth: biometrics,
            settingsRepository: settings
        )

        do {
            _ = try await useCase.execute()
            XCTFail("Expected session expired")
        } catch let error as AuthError {
            XCTAssertEqual(error, .sessionExpired)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testExecute_returnsSessionWhenBiometricsSucceed() async throws {
        let repository = MockAuthRepository()
        repository.storedSession = AuthSession(username: "demo", token: "abc", createdAt: .now)
        let biometrics = MockBiometricAuth()
        let settings = MockSettingsRepository()
        let useCase = AuthenticateWithBiometricsUseCase(
            authRepository: repository,
            biometricAuth: biometrics,
            settingsRepository: settings
        )

        let session = try await useCase.execute()

        XCTAssertEqual(session.username, "demo")
    }

    func testCanUseBiometrics_requiresStoredSession() {
        let repository = MockAuthRepository()
        let biometrics = MockBiometricAuth()
        let settings = MockSettingsRepository()
        let useCase = AuthenticateWithBiometricsUseCase(
            authRepository: repository,
            biometricAuth: biometrics,
            settingsRepository: settings
        )

        XCTAssertFalse(useCase.canUseBiometrics)

        repository.storedSession = AuthSession(username: "demo", token: "abc", createdAt: .now)
        XCTAssertTrue(useCase.canUseBiometrics)
    }

    func testExecute_throwsWhenBiometricsUnavailable() async {
        let repository = MockAuthRepository()
        repository.storedSession = AuthSession(username: "demo", token: "abc", createdAt: .now)
        let biometrics = MockBiometricAuth()
        biometrics.canEvaluateBiometrics = false
        let settings = MockSettingsRepository()
        let useCase = AuthenticateWithBiometricsUseCase(
            authRepository: repository,
            biometricAuth: biometrics,
            settingsRepository: settings
        )

        do {
            _ = try await useCase.execute()
            XCTFail("Expected biometrics unavailable")
        } catch let error as AuthError {
            XCTAssertEqual(error, .biometricsUnavailable)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testExecute_throwsWhenBiometricsFails() async {
        let repository = MockAuthRepository()
        repository.storedSession = AuthSession(username: "demo", token: "abc", createdAt: .now)
        let biometrics = MockBiometricAuth()
        biometrics.authenticateResult = .failure(AuthError.biometricsFailed)
        let settings = MockSettingsRepository()
        let useCase = AuthenticateWithBiometricsUseCase(
            authRepository: repository,
            biometricAuth: biometrics,
            settingsRepository: settings
        )

        do {
            _ = try await useCase.execute()
            XCTFail("Expected biometrics failed")
        } catch let error as AuthError {
            XCTAssertEqual(error, .biometricsFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

@MainActor
final class AuthErrorTests: XCTestCase {
    func testLocalizationKeys_matchExpectedMessages() {
        XCTAssertEqual(AuthError.invalidCredentials.localizationKey, "Invalid username or password.")
        XCTAssertEqual(AuthError.sessionExpired.localizationKey, "Your session has expired. Please sign in again.")
        XCTAssertEqual(AuthError.biometricsUnavailable.localizationKey, "Biometric authentication is not available.")
        XCTAssertEqual(AuthError.biometricsFailed.localizationKey, "Biometric authentication failed.")
    }
}
