import Foundation

struct AuthCredentials: Sendable {
    let username: String
    let password: String
}

struct AuthSession: Sendable {
    let username: String
    let token: String
    let createdAt: Date
}

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case biometricsUnavailable
    case biometricsFailed
    case sessionExpired

    var localizationKey: String {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password."
        case .biometricsUnavailable:
            return "Biometric authentication is not available."
        case .biometricsFailed:
            return "Biometric authentication failed."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        }
    }

    var errorDescription: String? {
        String(localized: String.LocalizationValue(localizationKey))
    }
}

extension AuthSession: Codable {}
