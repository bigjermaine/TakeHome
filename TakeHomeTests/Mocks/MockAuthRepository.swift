//
//  MockAuthRepository.swift
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
