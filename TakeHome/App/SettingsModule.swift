//
//  SettingsModule.swift
//  TakeHome
//

import Foundation

@MainActor
final class SettingsModule {
    let settingsRepository: SettingsRepositoryProtocol
    let loadSettingsUseCase: LoadSettingsUseCase
    let updateSettingsUseCase: UpdateSettingsUseCase
    let appPreferencesStore: AppPreferencesStore

    init() {
        settingsRepository = SettingsRepository()
        loadSettingsUseCase = LoadSettingsUseCase(settingsRepository: settingsRepository)
        updateSettingsUseCase = UpdateSettingsUseCase(settingsRepository: settingsRepository)
        appPreferencesStore = AppPreferencesStore(
            loadSettingsUseCase: loadSettingsUseCase,
            updateSettingsUseCase: updateSettingsUseCase
        )
    }
}
