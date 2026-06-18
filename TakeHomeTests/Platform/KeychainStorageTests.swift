//
//  KeychainStorageTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

final class InMemoryKeychainTests: XCTestCase {
    func testSave_read_returnsStoredData() throws {
        let keychain = InMemoryKeychain()
        let payload = Data("session-token".utf8)

        try keychain.save(payload, account: "auth.session")
        let read = try keychain.read(account: "auth.session")

        XCTAssertEqual(read, payload)
    }

    func testSave_overwritesExistingAccount() throws {
        let keychain = InMemoryKeychain()

        try keychain.save(Data("first".utf8), account: "auth.session")
        try keychain.save(Data("second".utf8), account: "auth.session")

        let read = try keychain.read(account: "auth.session")
        XCTAssertEqual(read, Data("second".utf8))
    }

    func testRead_missingAccount_returnsNil() throws {
        let keychain = InMemoryKeychain()

        XCTAssertNil(try keychain.read(account: "missing"))
    }

    func testDelete_removesAccount() throws {
        let keychain = InMemoryKeychain()
        try keychain.save(Data("value".utf8), account: "auth.session")

        try keychain.delete(account: "auth.session")

        XCTAssertNil(try keychain.read(account: "auth.session"))
    }
}

final class KeychainServiceTests: XCTestCase {
    func testSave_read_roundTrip() throws {
        let serviceName = "com.takehome.tests.\(UUID().uuidString)"
        let keychain = KeychainService(service: serviceName)
        let payload = Data("keychain-round-trip".utf8)

        try keychain.save(payload, account: "test.account")
        let read = try keychain.read(account: "test.account")

        XCTAssertEqual(read, payload)
        try keychain.delete(account: "test.account")
    }
}
