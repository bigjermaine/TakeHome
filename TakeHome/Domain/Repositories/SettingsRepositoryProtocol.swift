//
//  SettingsRepositoryProtocol.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

protocol SettingsRepositoryProtocol: Sendable {
    func theme() -> AppTheme
    func setTheme(_ theme: AppTheme)
    func language() -> AppLanguage
    func setLanguage(_ language: AppLanguage)
    func hapticsEnabled() -> Bool
    func setHapticsEnabled(_ enabled: Bool)
    func requireBiometricsOnLaunch() -> Bool
    func setRequireBiometricsOnLaunch(_ required: Bool)
}
