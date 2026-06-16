//
//  InMemoryKeychain.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
@testable import TakeHome

final class InMemoryKeychain: KeychainStoring, @unchecked Sendable {
    private var storage: [String: Data] = [:]

    func save(_ data: Data, account: String) throws {
        storage[account] = data
    }

    func read(account: String) throws -> Data? {
        storage[account]
    }

    func delete(account: String) throws {
        storage.removeValue(forKey: account)
    }
}
