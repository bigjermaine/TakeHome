//
//  SettingsUseCaseTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class SettingsUseCaseTests: XCTestCase {
    func testLoadSettings_readsRepositoryValues() {
        let repository = MockSettingsRepository()
        repository.themeValue = .dark
        repository.languageValue = .hebrew
        repository.hapticsValue = false
        repository.requireBiometricsValue = true

        let loadUseCase = LoadSettingsUseCase(settingsRepository: repository)

        XCTAssertEqual(loadUseCase.theme(), .dark)
        XCTAssertEqual(loadUseCase.language(), .hebrew)
        XCTAssertFalse(loadUseCase.hapticsEnabled())
        XCTAssertTrue(loadUseCase.requireBiometricsOnLaunch())
    }

    func testUpdateSettings_writesRepositoryValues() {
        let repository = MockSettingsRepository()
        let updateUseCase = UpdateSettingsUseCase(settingsRepository: repository)

        updateUseCase.setTheme(.dark)
        updateUseCase.setLanguage(.hebrew)
        updateUseCase.setHapticsEnabled(false)
        updateUseCase.setRequireBiometricsOnLaunch(true)

        XCTAssertEqual(repository.themeValue, .dark)
        XCTAssertEqual(repository.languageValue, .hebrew)
        XCTAssertFalse(repository.hapticsValue)
        XCTAssertTrue(repository.requireBiometricsValue)
    }
}
