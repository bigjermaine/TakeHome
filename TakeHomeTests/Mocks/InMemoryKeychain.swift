//
//  InMemoryKeychain.swift
//  TakeHomeTests
//

import Foundation
@testable import TakeHome

struct InMemoryKeychain: KeychainStoring, Sendable {
    private final class Storage: @unchecked Sendable {
        let lock = NSLock()
        var values: [String: Data] = [:]
    }

    private let storage = Storage()

    func save(_ data: Data, account: String) throws {
        storage.lock.lock()
        defer { storage.lock.unlock() }
        storage.values[account] = data
    }

    func read(account: String) throws -> Data? {
        storage.lock.lock()
        defer { storage.lock.unlock() }
        return storage.values[account]
    }

    func delete(account: String) throws {
        storage.lock.lock()
        defer { storage.lock.unlock() }
        storage.values.removeValue(forKey: account)
    }
}
