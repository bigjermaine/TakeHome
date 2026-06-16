//
//  MockBiometricAuth.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
@testable import TakeHome

final class MockBiometricAuth: BiometricAuthProtocol, @unchecked Sendable {
    var canEvaluateBiometrics = true
    var biometryName = "Face ID"
    var authenticateResult: Result<Void, Error> = .success(())

    func authenticate(reason: String) async throws {
        try authenticateResult.get()
    }
}
