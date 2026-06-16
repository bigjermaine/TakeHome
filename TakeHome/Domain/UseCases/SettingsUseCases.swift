//
//  SettingsUseCases.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

struct LoadSettingsUseCase: Sendable {
    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }

    func theme() -> AppTheme {
        settingsRepository.theme()
    }

    func language() -> AppLanguage {
        settingsRepository.language()
    }

    func hapticsEnabled() -> Bool {
        settingsRepository.hapticsEnabled()
    }

    func requireBiometricsOnLaunch() -> Bool {
        settingsRepository.requireBiometricsOnLaunch()
    }
}

struct UpdateSettingsUseCase: Sendable {
    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }

    func setTheme(_ theme: AppTheme) {
        settingsRepository.setTheme(theme)
    }

    func setLanguage(_ language: AppLanguage) {
        settingsRepository.setLanguage(language)
    }

    func setHapticsEnabled(_ enabled: Bool) {
        settingsRepository.setHapticsEnabled(enabled)
    }

    func setRequireBiometricsOnLaunch(_ required: Bool) {
        settingsRepository.setRequireBiometricsOnLaunch(required)
    }
}
