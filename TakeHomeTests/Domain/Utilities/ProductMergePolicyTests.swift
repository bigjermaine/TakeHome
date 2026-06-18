//
//  ProductMergePolicyTests.swift
//  TakeHomeTests
//

import XCTest
@testable import TakeHome

final class ProductMergePolicyTests: XCTestCase {
    func testDisplayFromRemote_prefersLocalAndHidesDeleted() {
        let remote = [Product.fixture(id: 1, title: "API"), Product.fixture(id: 2, title: "Other")]
        let local: [Int: Product] = [
            1: .fixture(id: 1, title: "Local", isLocalOnly: true),
            2: .fixture(id: 2, title: "Hidden", isDeleted: true)
        ]

        let display = ProductMergePolicy.displayFromRemote(remote, localByID: local)

        XCTAssertEqual(display.map(\.id), [1])
        XCTAssertEqual(display.first?.title, "Local")
    }

    func testDisplayFromRemote_usesRemoteWhenLocalMissing() {
        let remote = [Product.fixture(id: 5, title: "Remote")]

        let display = ProductMergePolicy.displayFromRemote(remote, localByID: [:])

        XCTAssertEqual(display.map(\.title), ["Remote"])
    }

    func testPrependFirstPageLocalOnly_prependsNegativeIDsOnFirstPageOnly() {
        let display = [Product.fixture(id: 1), Product.fixture(id: 2)]
        let localOnly = [
            Product.fixture(id: -1, title: "Local A", isLocalOnly: true),
            Product.fixture(id: -2, title: "Local B", isLocalOnly: true)
        ]

        let firstPage = ProductMergePolicy.prependFirstPageLocalOnly(
            to: display,
            localOnlyProducts: localOnly,
            skip: 0
        )
        let nextPage = ProductMergePolicy.prependFirstPageLocalOnly(
            to: display,
            localOnlyProducts: localOnly,
            skip: 20
        )

        XCTAssertEqual(firstPage.map(\.id), [-1, -2, 1, 2])
        XCTAssertEqual(nextPage.map(\.id), [1, 2])
    }

    func testPrependFirstPageLocalOnly_excludesDeletedAndDuplicateIDs() {
        let display = [Product.fixture(id: 1)]
        let localOnly = [
            Product.fixture(id: -1, title: "Local", isLocalOnly: true),
            Product.fixture(id: -2, title: "Deleted", isLocalOnly: true, isDeleted: true),
            Product.fixture(id: 1, title: "Duplicate", isLocalOnly: true)
        ]

        let merged = ProductMergePolicy.prependFirstPageLocalOnly(
            to: display,
            localOnlyProducts: localOnly,
            skip: 0
        )

        XCTAssertEqual(merged.map(\.id), [-1, 1])
    }

    func testPrependSearchLocalMatches_addsOnlyMissingMatchesOnFirstPage() {
        let display = [Product.fixture(id: 1, title: "iPhone")]
        let localMatches = [
            Product.fixture(id: -3, title: "iPhone Case", isLocalOnly: true),
            Product.fixture(id: 1, title: "Edited iPhone", isLocalOnly: true)
        ]

        let merged = ProductMergePolicy.prependSearchLocalMatches(
            to: display,
            localMatches: localMatches,
            skip: 0,
            searchQuery: "iphone"
        )
        let paginated = ProductMergePolicy.prependSearchLocalMatches(
            to: display,
            localMatches: localMatches,
            skip: 20,
            searchQuery: "iphone"
        )
        let noSearch = ProductMergePolicy.prependSearchLocalMatches(
            to: display,
            localMatches: localMatches,
            skip: 0,
            searchQuery: nil
        )

        XCTAssertEqual(merged.map(\.id), [-3, 1])
        XCTAssertEqual(paginated.map(\.id), [1])
        XCTAssertEqual(noSearch.map(\.id), [1])
    }

    func testDeduplicated_keepsFirstOccurrence() {
        let products = [
            Product.fixture(id: 1, title: "First"),
            Product.fixture(id: 1, title: "Duplicate"),
            Product.fixture(id: 2, title: "Second")
        ]

        let deduplicated = ProductMergePolicy.deduplicated(products)

        XCTAssertEqual(deduplicated.count, 2)
        XCTAssertEqual(deduplicated.first?.title, "First")
    }

    func testTotalCount_usesMaxForSearch() {
        XCTAssertEqual(
            ProductMergePolicy.totalCount(apiTotal: 5, displayCount: 3, searchQuery: "phone"),
            5
        )
        XCTAssertEqual(
            ProductMergePolicy.totalCount(apiTotal: 5, displayCount: 7, searchQuery: "phone"),
            7
        )
        XCTAssertEqual(
            ProductMergePolicy.totalCount(apiTotal: 100, displayCount: 7, searchQuery: nil),
            100
        )
    }
}
