//
//  ProductLocalDataSource.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class ProductLocalDataSource {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func allRecords() throws -> [ProductRecord] {
        let descriptor = FetchDescriptor<ProductRecord>(
            sortBy: [SortDescriptor(\.title, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func record(id: Int) throws -> ProductRecord? {
        let descriptor = FetchDescriptor<ProductRecord>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func upsert(_ product: Product) throws {
        if let existing = try record(id: product.id) {
            existing.apply(product)
        } else {
            modelContext.insert(
                ProductRecord(
                    id: product.id,
                    title: product.title,
                    productDescription: product.productDescription,
                    price: product.price,
                    category: product.category,
                    thumbnailURL: product.thumbnailURL?.absoluteString,
                    imageURLs: product.imageURLs.map(\.absoluteString),
                    brand: product.brand,
                    rating: product.rating,
                    stock: product.stock,
                    isLocalOnly: product.isLocalOnly,
                    isDeleted: product.isDeleted
                )
            )
        }
        try modelContext.save()
    }

    func upsertMany(_ products: [Product]) throws {
        for product in products {
            if let existing = try record(id: product.id) {
                if existing.isLocalOnly || existing.isDeleted {
                    continue
                }
                existing.apply(product)
            } else {
                modelContext.insert(
                    ProductRecord(
                        id: product.id,
                        title: product.title,
                        productDescription: product.productDescription,
                        price: product.price,
                        category: product.category,
                        thumbnailURL: product.thumbnailURL?.absoluteString,
                        imageURLs: product.imageURLs.map(\.absoluteString),
                        brand: product.brand,
                        rating: product.rating,
                        stock: product.stock,
                        isLocalOnly: product.isLocalOnly,
                        isDeleted: product.isDeleted
                    )
                )
            }
        }
        try modelContext.save()
    }

    func deleteRecord(id: Int) throws {
        if let record = try record(id: id) {
            if record.isLocalOnly {
                modelContext.delete(record)
            } else {
                record.isDeleted = true
                record.updatedAt = .now
            }
            try modelContext.save()
        }
    }

    func resetLocalChanges() throws {
        let records = try allRecords()
        for record in records where record.isLocalOnly || record.isDeleted {
            modelContext.delete(record)
        }
        try modelContext.save()
    }

    func nextLocalID() throws -> Int {
        let records = try allRecords()
        let minID = records.map(\.id).min() ?? 0
        return min(minID, 0) - 1
    }

    func categories() throws -> [String] {
        Array(Set(try allRecords().filter { !$0.isDeleted }.map(\.category))).sorted()
    }
}
