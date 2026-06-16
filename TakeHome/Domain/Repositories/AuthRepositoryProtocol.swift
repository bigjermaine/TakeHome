//
//  AuthRepositoryProtocol.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func login(credentials: AuthCredentials) async throws -> AuthSession
    func saveSession(_ session: AuthSession) throws
    func loadSession() throws -> AuthSession?
    func clearSession() throws
    func hasStoredSession() -> Bool
}

protocol BiometricAuthProtocol: Sendable {
    var canEvaluateBiometrics: Bool { get }
    var biometryName: String { get }
    func authenticate(reason: String) async throws
}
