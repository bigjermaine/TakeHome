import Foundation
import Combine

@MainActor
final class ProductDetailViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case loaded(Product)
        case error(String)
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var isFavorite = false

    let productID: Int

    private let fetchProductDetailUseCase: FetchProductDetailUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let deleteProductUseCase: DeleteProductUseCase
    private let imageLoader: ImageLoadingProtocol
    private let router: AppRouter

    init(
        productID: Int,
        fetchProductDetailUseCase: FetchProductDetailUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        deleteProductUseCase: DeleteProductUseCase,
        imageLoader: ImageLoadingProtocol,
        router: AppRouter
    ) {
        self.productID = productID
        self.fetchProductDetailUseCase = fetchProductDetailUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.deleteProductUseCase = deleteProductUseCase
        self.imageLoader = imageLoader
        self.router = router
    }

    func load() async {
        let isRefresh: Bool
        if case .loaded = viewState {
            isRefresh = true
        } else {
            isRefresh = false
            viewState = .loading
        }

        do {
            let product = try await fetchProductDetailUseCase.execute(id: productID)
            guard !Task.isCancelled else { return }

            isFavorite = (try? toggleFavoriteUseCase.isFavorite(productID: productID)) ?? false
            imageLoader.prefetch(urls: product.imageURLs)
            viewState = .loaded(product)
        } catch is CancellationError {
            guard !isRefresh else { return }
            if case .loading = viewState {
                viewState = .error("Unable to load product.")
            }
        } catch {
            if isRefresh, case .loaded = viewState {
                return
            }
            viewState = .error(error.localizedDescription)
        }
    }

    func toggleFavorite() {
        do {
            if isFavorite {
                _ = try toggleFavoriteUseCase.remove(productID: productID)
                isFavorite = false
            } else {
                try toggleFavoriteUseCase.add(productID: productID)
                isFavorite = true
            }
            HapticFeedback.play(.selection)
        } catch {
            // Keep current favorite state on failure.
        }
    }

    func openEditor() {
        router.openProductEditor(id: productID)
    }

    func deleteProduct() async -> Bool {
        do {
            try await deleteProductUseCase.execute(id: productID)
            HapticFeedback.play(.success)
            return true
        } catch {
            HapticFeedback.play(.error)
            return false
        }
    }
}
