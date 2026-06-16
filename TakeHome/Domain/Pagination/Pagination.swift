import Foundation

struct PageRequest: Equatable, Sendable {
    let skip: Int
    let limit: Int

    static func first(limit: Int) -> PageRequest {
        PageRequest(skip: 0, limit: limit)
    }

    func next(currentItemCount: Int) -> PageRequest {
        PageRequest(skip: skip + currentItemCount, limit: limit)
    }
}

struct PaginatedResult<Item: Sendable>: Sendable {
    let items: [Item]
    let total: Int
    let request: PageRequest

    var hasMore: Bool {
        request.skip + items.count < total
    }

    func nextRequest(currentItemCount: Int) -> PageRequest? {
        guard hasMore else { return nil }
        return request.next(currentItemCount: currentItemCount)
    }
}
