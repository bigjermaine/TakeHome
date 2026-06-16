//
//  ProductEditorViewModel.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
import Combine

@MainActor
final class ProductEditorViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case editing
        case saving
        case error(String)
    }

    @Published var title = ""
    @Published var productDescription = ""
    @Published var price = ""
    @Published var category = ""
    @Published var brand = ""
    @Published var stock = ""
    @Published var rating = ""
    @Published var thumbnailURL = ""
    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var isEditingExisting = false

    private let productID: Int?
    private let fetchProductDetailUseCase: FetchProductDetailUseCase
    private let saveProductUseCase: SaveProductUseCase
    private let router: AppRouter

    init(
        productID: Int?,
        fetchProductDetailUseCase: FetchProductDetailUseCase,
        saveProductUseCase: SaveProductUseCase,
        router: AppRouter
    ) {
        self.productID = productID
        self.fetchProductDetailUseCase = fetchProductDetailUseCase
        self.saveProductUseCase = saveProductUseCase
        self.router = router
        isEditingExisting = productID != nil
    }

    func load() async {
        guard let productID else {
            viewState = .editing
            return
        }

        if title.isEmpty {
            viewState = .loading
        }

        do {
            let product = try await fetchProductDetailUseCase.execute(id: productID)
            apply(product)
            viewState = .editing
        } catch is CancellationError {
            if case .loading = viewState {
                viewState = .editing
            }
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func save() async -> Bool {
        guard validate() else { return false }

        viewState = .saving
        let product = Product(
            id: productID ?? 0,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            productDescription: productDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            price: Double(price) ?? 0,
            category: category.trimmingCharacters(in: .whitespacesAndNewlines),
            thumbnailURL: URL(string: thumbnailURL.trimmingCharacters(in: .whitespacesAndNewlines)),
            imageURLs: [URL(string: thumbnailURL.trimmingCharacters(in: .whitespacesAndNewlines))].compactMap { $0 },
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            rating: Double(rating) ?? 0,
            stock: Int(stock) ?? 0,
            isLocalOnly: productID == nil,
            isDeleted: false
        )

        do {
            try await saveProductUseCase.execute(product)
            viewState = .editing
            HapticFeedback.play(.success)
            return true
        } catch {
            viewState = .error(error.localizedDescription)
            HapticFeedback.play(.error)
            return false
        }
    }

    private func apply(_ product: Product) {
        title = product.title
        productDescription = product.productDescription
        price = String(product.price)
        category = product.category
        brand = product.brand
        stock = String(product.stock)
        rating = String(product.rating)
        thumbnailURL = product.thumbnailURL?.absoluteString ?? ""
    }

    private func validate() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewState = .error("Title is required.")
            HapticFeedback.play(.error)
            return false
        }
        if category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewState = .error("Category is required.")
            HapticFeedback.play(.error)
            return false
        }
        if Double(price) == nil {
            viewState = .error("Price must be a valid number.")
            HapticFeedback.play(.error)
            return false
        }
        viewState = .editing
        return true
    }
}
