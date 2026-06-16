//
//  AuthRepository.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
import Security
import Combine



final class AuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private enum Keys {
        static let sessionAccount = "auth.session"
    }

    private let keychain: KeychainService
    private let validUsername = "demo"
    private let validPassword = "password123"

    init(keychain: KeychainService) {
        self.keychain = keychain
    }

    func login(credentials: AuthCredentials) async throws -> AuthSession {
        try await Task.sleep(nanoseconds: 400_000_000)

        guard credentials.username == validUsername,
              credentials.password == validPassword else {
            throw AuthError.invalidCredentials
        }

        return AuthSession(
            username: credentials.username,
            token: UUID().uuidString,
            createdAt: .now
        )
    }

    func saveSession(_ session: AuthSession) throws {
        let payload = try JSONEncoder().encode(session)
        try keychain.save(payload, account: Keys.sessionAccount)
    }

    func loadSession() throws -> AuthSession? {
        guard let data = try keychain.read(account: Keys.sessionAccount) else {
            return nil
        }
        return try JSONDecoder().decode(AuthSession.self, from: data)
    }

    func clearSession() throws {
        try keychain.delete(account: Keys.sessionAccount)
    }

    func hasStoredSession() -> Bool {
        (try? loadSession()) != nil
    }
}
