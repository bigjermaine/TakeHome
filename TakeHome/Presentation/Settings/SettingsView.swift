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
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { preferences.theme },
                        set: { preferences.setTheme($0) }
                    )) {
                        Text("System").tag(AppTheme.system)
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                    }
                }

                Section("Language") {
                    Picker("Language", selection: Binding(
                        get: { preferences.language },
                        set: { preferences.setLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }

                Section("Security") {
                    Toggle("Require Face ID on Launch", isOn: Binding(
                        get: { preferences.requireBiometricsOnLaunch },
                        set: { preferences.setRequireBiometricsOnLaunch($0) }
                    ))
                    .disabled(!router.isBiometricAuthAvailable)

                    if !router.isBiometricAuthAvailable {
                        Text("Face ID or Touch ID is not available on this device.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: Binding(
                        get: { preferences.hapticsEnabled },
                        set: { preferences.setHapticsEnabled($0) }
                    ))
                }

                Section {
                    Button(role: .destructive) {
                        HapticFeedback.play(.warning)
                        Task { await router.logout() }
                    } label: {
                        Text("Log Out")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
