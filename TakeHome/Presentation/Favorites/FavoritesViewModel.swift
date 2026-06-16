import Foundation
import SwiftUI
import Combine

struct UndoAction: Equatable {
    let product: Product
}

@MainActor
final class FavoritesViewModel: ObservableObject {
 
    @Published private(set) var favorites: [Product] = []
    @Published private(set) var undoAction: UndoAction?
    @Published private(set) var errorMessage: String?

    private let fetchFavoritesUseCase: FetchFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let router: AppRouter
    private var undoTask: Task<Void, Never>?

    init(
        fetchFavoritesUseCase: FetchFavoritesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        router: AppRouter
    ) {
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.router = router
    }

    func load() {
        do {
            favorites = try fetchFavoritesUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(product: Product) {
        do {
            guard let removed = try toggleFavoriteUseCase.remove(productID: product.id) else {
                return
            }
            favorites.removeAll { $0.id == product.id }
            presentUndo(for: removed)
            HapticFeedback.play(.warning)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func undoRemove() {
        guard let undoAction else { return }
        do {
            try toggleFavoriteUseCase.add(productID: undoAction.product.id)
            favorites.insert(undoAction.product, at: 0)
            self.undoAction = nil
            undoTask?.cancel()
            HapticFeedback.play(.success)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openDetail(productID: Int) {
        router.openFavoriteProductDetail(id: productID)
    }

    private func presentUndo(for product: Product) {
        undoAction = UndoAction(product: product)
        undoTask?.cancel()
        undoTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await MainActor.run {
                if self.undoAction?.product.id == product.id {
                    self.undoAction = nil
                }
            }
        }
    }
}
