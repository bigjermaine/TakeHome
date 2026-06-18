//
//  SettingsRepository.swift
//  TakeHome
//

import Foundation

struct SettingsRepository: SettingsRepositoryProtocol, Sendable {
    private enum Keys {
        static let theme = "settings.theme"
        static let language = "settings.language"
        static let hapticsEnabled = "settings.hapticsEnabled"
        static let requireBiometricsOnLaunch = "settings.requireBiometricsOnLaunch"
    }

    private let defaultsSuiteName: String?

    init(defaultsSuiteName: String? = nil) {
        self.defaultsSuiteName = defaultsSuiteName
    }

    private var defaults: UserDefaults {
        if let defaultsSuiteName, let suite = UserDefaults(suiteName: defaultsSuiteName) {
            return suite
        }
        return .standard
    }

    func theme() -> AppTheme {
        guard let rawValue = defaults.string(forKey: Keys.theme),
              let theme = AppTheme(rawValue: rawValue) else {
            return .system
        }
        return theme
    }

    func setTheme(_ theme: AppTheme) {
        defaults.set(theme.rawValue, forKey: Keys.theme)
    }

    func language() -> AppLanguage {
        guard let rawValue = defaults.string(forKey: Keys.language),
              let language = AppLanguage(rawValue: rawValue) else {
            return .english
        }
        return language
    }

    func setLanguage(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: Keys.language)
    }

    func hapticsEnabled() -> Bool {
        if defaults.object(forKey: Keys.hapticsEnabled) == nil {
            return true
        }
        return defaults.bool(forKey: Keys.hapticsEnabled)
    }

    func setHapticsEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.hapticsEnabled)
    }

    func requireBiometricsOnLaunch() -> Bool {
        if defaults.object(forKey: Keys.requireBiometricsOnLaunch) == nil {
            return true
        }
        return defaults.bool(forKey: Keys.requireBiometricsOnLaunch)
    }

    func setRequireBiometricsOnLaunch(_ required: Bool) {
        defaults.set(required, forKey: Keys.requireBiometricsOnLaunch)
    }
}
