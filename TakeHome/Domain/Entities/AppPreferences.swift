//
//  AppPreferences.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

enum AppTheme: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }
}

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case hebrew = "he"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .hebrew:
            return "עברית"
        }
    }

    var localeIdentifier: String { rawValue }
}
