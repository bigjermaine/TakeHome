//
//  AppLocalization.swift
//  TakeHome
//

import Foundation

enum AppLocalization {
    static func string(_ key: String, locale: Locale) -> String {
        var resource = LocalizedStringResource(stringLiteral: key)
        resource.locale = locale
        return String(localized: resource)
    }
}
