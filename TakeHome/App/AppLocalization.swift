//
//  AppLocalization.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

enum AppLocalization {
    static func string(_ key: String, locale: Locale) -> String {
        String(localized: String.LocalizationValue(stringLiteral: key), locale: locale)
    }
}
