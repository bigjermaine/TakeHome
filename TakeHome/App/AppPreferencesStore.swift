import Foundation
import SwiftUI
import Combine

@MainActor
final class AppPreferencesStore: ObservableObject {
    @Published private(set) var language: AppLanguage
    @Published private(set) var theme: AppTheme
    @Published private(set) var hapticsEnabled: Bool
    @Published private(set) var requireBiometricsOnLaunch: Bool

    private let updateSettingsUseCase: UpdateSettingsUseCase

    init(
        loadSettingsUseCase: LoadSettingsUseCase,
        updateSettingsUseCase: UpdateSettingsUseCase
    ) {
        self.updateSettingsUseCase = updateSettingsUseCase
        language = loadSettingsUseCase.language()
        theme = loadSettingsUseCase.theme()
        hapticsEnabled = loadSettingsUseCase.hapticsEnabled()
        requireBiometricsOnLaunch = loadSettingsUseCase.requireBiometricsOnLaunch()
    }

    var locale: Locale {
        Locale(identifier: language.localeIdentifier)
    }

    var preferredColorScheme: ColorScheme? {
        switch theme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    func setLanguage(_ language: AppLanguage) {
        guard self.language != language else { return }
        self.language = language
        updateSettingsUseCase.setLanguage(language)
        HapticFeedback.play(.selection)
    }

    func setTheme(_ theme: AppTheme) {
        guard self.theme != theme else { return }
        self.theme = theme
        updateSettingsUseCase.setTheme(theme)
        HapticFeedback.play(.selection)
    }

    func setHapticsEnabled(_ enabled: Bool) {
        guard hapticsEnabled != enabled else { return }
        hapticsEnabled = enabled
        updateSettingsUseCase.setHapticsEnabled(enabled)
        if enabled {
            HapticFeedback.play(.selection)
        }
    }

    func setRequireBiometricsOnLaunch(_ required: Bool) {
        guard requireBiometricsOnLaunch != required else { return }
        requireBiometricsOnLaunch = required
        updateSettingsUseCase.setRequireBiometricsOnLaunch(required)
        HapticFeedback.play(.selection)
    }
}
