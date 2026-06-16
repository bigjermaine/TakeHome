import Foundation
import Combine

@MainActor
final class ProductListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isSearching = false
    @Published private(set) var favoriteIDs: Set<Int> = []
    @Published private(set) var categories: [String] = []
    @Published private(set) var hasMore = true
    @Published var searchQuery = ""
    @Published var selectedCategory = "All"
    @Published var sortOption: ProductSortOption = .titleAscending

    private let pageSize = 20
    private var pageRequest = PageRequest.first(limit: 20)
    private var hasInitiallyLoaded = false
    private var searchTask: Task<Void, Never>?

    private let fetchProductsUseCase: FetchProductsUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let fetchFavoritesUseCase: FetchFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let resetProductsUseCase: ResetProductsUseCase
    private let router: AppRouter

    init(
        fetchProductsUseCase: FetchProductsUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        fetchFavoritesUseCase: FetchFavoritesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        resetProductsUseCase: ResetProductsUseCase,
        router: AppRouter
    ) {
        self.fetchProductsUseCase = fetchProductsUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.resetProductsUseCase = resetProductsUseCase
        self.router = router
    }

    var isSearchActive: Bool {
        normalizedSearchQuery != nil
    }

    func loadInitially() async {
        guard !hasInitiallyLoaded else {
            reloadFavorites()
            return
        }
        hasInitiallyLoaded = true
        loadCachedData()
        await refresh(showLoadingUI: true)
    }

    func reloadFromCache() {
        loadCachedData()
    }

    func refresh(showLoadingUI: Bool = false, successHaptic: Bool = false) async {
        pageRequest = PageRequest.first(limit: pageSize)
        hasMore = true

        let isActiveSearch = isSearchActive
        if isActiveSearch {
            isSearching = true
        }

        let shouldShowFullScreenLoading = showLoadingUI && products.isEmpty && !isActiveSearch
        if shouldShowFullScreenLoading || (showLoadingUI && products.isEmpty && isActiveSearch) {
            viewState = .loading
        }

        defer { isSearching = false }

        do {
            let page = try await fetchProductsUseCase.execute(
                skip: pageRequest.skip,
                limit: pageRequest.limit,
                searchQuery: normalizedSearchQuery,
                category: normalizedCategory,
                sort: sortOption
            )
            if page.products != products {
                products = page.products
            }
            hasMore = page.hasMore
            viewState = .loaded
            reloadFavorites()
            reloadCategories()
            if successHaptic {
                HapticFeedback.play(.success)
            }
        } catch is CancellationError {
            if !products.isEmpty {
                viewState = .loaded
            } else if isActiveSearch {
                loadCachedData()
            }
        } catch {
            if isActiveSearch {
                loadCachedData()
            }
            if products.isEmpty {
                viewState = .error(error.localizedDescription)
            } else {
                viewState = .loaded
            }
        }
    }

    func loadMoreIfNeeded(currentProduct: Product) async {
        guard hasMore, !isLoadingMore, viewState != .loading, currentProduct.id == products.last?.id else {
            return
        }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextRequest = PageRequest(skip: products.count, limit: pageSize)
        do {
            let page = try await fetchProductsUseCase.execute(
                skip: nextRequest.skip,
                limit: nextRequest.limit,
                searchQuery: normalizedSearchQuery,
                category: normalizedCategory,
                sort: sortOption
            )
            let existingIDs = Set(products.map(\.id))
            let newProducts = page.products.filter { !existingIDs.contains($0.id) }
            products.append(contentsOf: newProducts)
            hasMore = page.hasMore
            pageRequest = nextRequest
        } catch is CancellationError {
            return
        } catch {
            // Keep existing items visible when pagination fails.
        }
    }

    func applyFilters() async {
        searchTask?.cancel()
        await refresh(showLoadingUI: products.isEmpty)
    }

    func scheduleSearch() {
        searchTask?.cancel()

        guard isSearchActive else {
            isSearching = false
            Task { await refresh(showLoadingUI: products.isEmpty) }
            return
        }

        isSearching = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else {
                await MainActor.run { isSearching = false }
                return
            }
            await refresh()
        }
    }

    func toggleFavorite(productID: Int) {
        do {
            if try toggleFavoriteUseCase.isFavorite(productID: productID) {
                _ = try toggleFavoriteUseCase.remove(productID: productID)
                favoriteIDs.remove(productID)
            } else {
                try toggleFavoriteUseCase.add(productID: productID)
                favoriteIDs.insert(productID)
            }
            HapticFeedback.play(.selection)
        } catch {
            // Ignore favorite toggle errors in list UI.
        }
    }

    func isFavorite(productID: Int) -> Bool {
        favoriteIDs.contains(productID)
    }

    func openDetail(productID: Int) {
        router.openProductDetail(id: productID)
    }

    func openCreateProduct() {
        router.openProductEditor(id: nil)
    }

    func resetLocalChanges() async {
        viewState = .loading
        do {
            try await resetProductsUseCase.execute()
            HapticFeedback.play(.success)
            await refresh(showLoadingUI: true)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private var normalizedSearchQuery: String? {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? nil : query
    }

    private var normalizedCategory: String? {
        selectedCategory == "All" ? nil : selectedCategory
    }

    private func loadCachedData() {
        if let cached = try? fetchProductsUseCase.cached(
            searchQuery: normalizedSearchQuery,
            category: normalizedCategory,
            sort: sortOption
        ), !cached.isEmpty {
            products = cached
            viewState = .loaded
        }
        reloadFavorites()
        reloadCategories()
    }

    private func reloadFavorites() {
        if let favorites = try? fetchFavoritesUseCase.execute() {
            favoriteIDs = Set(favorites.map(\.id))
        }
    }

    private func reloadCategories() {
        let stored = (try? fetchCategoriesUseCase.execute()) ?? []
        categories = ["All"] + stored
    }
}
