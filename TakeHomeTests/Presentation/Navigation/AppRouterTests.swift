//
//  AppRouterTests.swift
//  TakeHomeTests
//
//  Created by jermaine daniel on 15/06/2026.
//

import XCTest
@testable import TakeHome

@MainActor
final class AppRouterTests: XCTestCase {
    func testPresentDeleteConfirmation_setsPresentationState() {
        let router = DIContainer().appRouter

        router.presentDeleteConfirmation(for: 42, isLocalOnly: true)

        XCTAssertEqual(router.deleteConfirmationProductID, 42)
        XCTAssertTrue(router.deleteConfirmationIsLocalOnly)
        XCTAssertTrue(router.isDeleteConfirmationPresented)
    }

    func testDismissDeleteConfirmation_clearsPresentationState() {
        let router = DIContainer().appRouter
        router.presentDeleteConfirmation(for: 42, isLocalOnly: false)

        router.dismissDeleteConfirmation()

        XCTAssertNil(router.deleteConfirmationProductID)
        XCTAssertFalse(router.deleteConfirmationIsLocalOnly)
        XCTAssertFalse(router.isDeleteConfirmationPresented)
    }

    func testOpenProductDetail_selectsProductsTabAndPushesPath() {
        let router = DIContainer().appRouter

        router.openProductDetail(id: 7)

        XCTAssertEqual(router.selectedTab, .products)
        XCTAssertEqual(router.productPath.count, 1)
    }

    func testShowMain_setsAppRoute() {
        let router = DIContainer().appRouter
        router.showLogin()

        router.showMain()

        XCTAssertEqual(router.appRoute, .main)
    }

    func testPopProductDetail_removesNavigationPath() {
        let router = DIContainer().appRouter
        router.openProductDetail(id: 5)
        router.popProductDetail(for: 5)

        XCTAssertEqual(router.productPath.count, 0)
    }
}
