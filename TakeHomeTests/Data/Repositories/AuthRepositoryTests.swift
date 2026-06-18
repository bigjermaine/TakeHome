//
//  AuthRepositoryTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class AuthRepositoryTests: XCTestCase {
    func testLogin_validCredentials_returnsSession() async throws {
        let repository = AuthRepository(keychain: InMemoryKeychain())

        let session = try await repository.login(
            credentials: AuthCredentials(username: "demo", password: "password123")
        )

        XCTAssertEqual(session.username, "demo")
        XCTAssertFalse(session.token.isEmpty)
    }

    func testLogin_invalidCredentials_throws() async {
        let repository = AuthRepository(keychain: InMemoryKeychain())

        do {
            _ = try await repository.login(
                credentials: AuthCredentials(username: "bad", password: "bad")
            )
            XCTFail("Expected invalid credentials")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSession_saveLoadClear_roundTrip() throws {
        let repository = AuthRepository(keychain: InMemoryKeychain())
        let session = AuthSession(username: "demo", token: "token-123", createdAt: .now)

        try repository.saveSession(session)
        XCTAssertTrue(repository.hasStoredSession())

        let loaded = try repository.loadSession()
        XCTAssertEqual(loaded?.username, "demo")
        XCTAssertEqual(loaded?.token, "token-123")

        try repository.clearSession()
        XCTAssertFalse(repository.hasStoredSession())
        XCTAssertNil(try repository.loadSession())
    }
}
