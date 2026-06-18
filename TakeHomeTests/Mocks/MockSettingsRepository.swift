//
//  MockSettingsRepository.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
@testable import TakeHome

@MainActor
final class MockSettingsRepository: SettingsRepositoryProtocol {
    var languageValue: AppLanguage = .english
    var themeValue: AppTheme = .system
    var hapticsValue = true
    var requireBiometricsValue = true

    func language() -> AppLanguage {
        languageValue
    }

    func theme() -> AppTheme {
        themeValue
    }

    func setLanguage(_ language: AppLanguage) {
        languageValue = language
    }

    func setTheme(_ theme: AppTheme) {
        themeValue = theme
    }

    func hapticsEnabled() -> Bool { hapticsValue }

    func setHapticsEnabled(_ enabled: Bool) {
        hapticsValue = enabled
    }

    func requireBiometricsOnLaunch() -> Bool { requireBiometricsValue }

    func setRequireBiometricsOnLaunch(_ required: Bool) {
        requireBiometricsValue = required
    }
}
