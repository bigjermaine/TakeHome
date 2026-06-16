import XCTest
@testable import TakeHome

final class PaginationTests: XCTestCase {
    func testFirstPageRequest_startsAtZero() {
        let request = PageRequest.first(limit: 20)

        XCTAssertEqual(request.skip, 0)
        XCTAssertEqual(request.limit, 20)
    }

    func testPaginatedResult_hasMoreWhenItemsRemain() {
        let result = PaginatedResult(
            items: Array(repeating: 1, count: 20),
            total: 100,
            request: PageRequest.first(limit: 20)
        )

        XCTAssertTrue(result.hasMore)
        XCTAssertNotNil(result.nextRequest(currentItemCount: 20))
    }

    func testPaginatedResult_hasNoMoreOnLastPage() {
        let result = PaginatedResult(
            items: Array(repeating: 1, count: 10),
            total: 30,
            request: PageRequest(skip: 20, limit: 20)
        )

        XCTAssertFalse(result.hasMore)
        XCTAssertNil(result.nextRequest(currentItemCount: 10))
    }

    func testNextRequest_advancesSkip() {
        let request = PageRequest(skip: 0, limit: 20)
        let next = request.next(currentItemCount: 20)

        XCTAssertEqual(next.skip, 20)
        XCTAssertEqual(next.limit, 20)
    }
}
