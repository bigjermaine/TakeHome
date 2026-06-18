//
//  SettingsView.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var preferences: AppPreferencesStore
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack {
            settingsForm
        }
        .environment(\.locale, preferences.locale)
        .id(preferences.language)
    }

    private var settingsForm: some View {
        Form {
            Section(localized("Appearance")) {
                Picker(localized("Theme"), selection: Binding(
                    get: { preferences.theme },
                    set: { preferences.setTheme($0) }
                )) {
                    Text(localized("System")).tag(AppTheme.system)
                    Text(localized("Light")).tag(AppTheme.light)
                    Text(localized("Dark")).tag(AppTheme.dark)
                }
            }

            Section(localized("Language")) {
                Picker(localized("Language"), selection: Binding(
                    get: { preferences.language },
                    set: { preferences.setLanguage($0) }
                )) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
            }

            Section(localized("Security")) {
                Toggle(localized("Require Face ID on Launch"), isOn: Binding(
                    get: { preferences.requireBiometricsOnLaunch },
                    set: { preferences.setRequireBiometricsOnLaunch($0) }
                ))
                .disabled(!router.isBiometricAuthAvailable)

                if !router.isBiometricAuthAvailable {
                    Text(localized("Face ID or Touch ID is not available on this device."))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section(localized("Feedback")) {
                Toggle(localized("Haptic Feedback"), isOn: Binding(
                    get: { preferences.hapticsEnabled },
                    set: { preferences.setHapticsEnabled($0) }
                ))
            }

            Section {
                Button(role: .destructive) {
                    HapticFeedback.play(.warning)
                    Task { await router.logout() }
                } label: {
                    Text(localized("Log Out"))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(localized("Settings"))
            }
        }
    }

    private func localized(_ key: String) -> String {
        AppLocalization.string(key, locale: preferences.locale)
    }
}
