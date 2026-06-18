//
//  SettingsModule.swift
//  TakeHome
//

import Foundation

@MainActor
final class SettingsModule {
    let loadSettingsUseCase: LoadSettingsUseCase
    let updateSettingsUseCase: UpdateSettingsUseCase
    let appPreferencesStore: AppPreferencesStore

    init() {
        let settingsRepository: SettingsRepositoryProtocol = SettingsRepository()
        loadSettingsUseCase = LoadSettingsUseCase(settingsRepository: settingsRepository)
        updateSettingsUseCase = UpdateSettingsUseCase(settingsRepository: settingsRepository)
        appPreferencesStore = AppPreferencesStore(
            loadSettingsUseCase: loadSettingsUseCase,
            updateSettingsUseCase: updateSettingsUseCase
        )
    }
}
