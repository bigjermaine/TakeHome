import SwiftUI

struct ProductsFlowView: View {
    let container: DIContainer
    @ObservedObject var viewModel: ProductListViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.productPath) {
            ProductListView(viewModel: viewModel)
                .onChange(of: router.productPath.count) { oldCount, newCount in
                    if newCount < oldCount {
                        viewModel.reloadFromCache()
                    }
                }
                .navigationDestination(for: ProductRoute.self) { route in
                    switch route {
                    case .detail(let productID):
                        ProductDetailView(
                            viewModel: container.makeProductDetailViewModel(productID: productID)
                        )
                        .id(productID)
                    case .editor(let productID):
                        ProductEditorView(
                            viewModel: container.makeProductEditorViewModel(productID: productID)
                        )
                    }
                }
        }
    }
}

struct ProductListView: View {
    @ObservedObject var viewModel: ProductListViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @Environment(\.locale) private var locale

    var body: some View {
        List {
            if !networkMonitor.isConnected {
                Section {
                    Label(localized("You're offline. Showing cached products."), systemImage: "wifi.slash")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            filtersSection
            contentSection
        }
        .navigationTitle("Products")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Reset") {
                    HapticFeedback.play(.warning)
                    Task { await viewModel.resetLocalChanges() }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticFeedback.play(.light)
                    viewModel.openCreateProduct()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: Text("Search products"))
        .onSubmit(of: .search) {
            Task { await viewModel.applyFilters() }
        }
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.scheduleSearch()
        }
        .task {
            await viewModel.loadInitially()
        }
        .refreshable {
            await viewModel.refresh(showLoadingUI: false, successHaptic: true)
        }
    }

    private func localized(_ key: String) -> String {
        AppLocalization.string(key, locale: locale)
    }

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isSearching && viewModel.products.isEmpty {
            statusSection(
                title: localized("Searching…"),
                systemImage: "magnifyingglass",
                description: String(format: localized("Looking for \"%@\""), viewModel.searchQuery)
            ) {
                ProgressView()
                    .padding(.top, 8)
            }
        } else if viewModel.viewState == .loading && viewModel.products.isEmpty {
            statusSection(
                title: localized("Loading Products"),
                systemImage: "bag",
                description: localized("Fetching the latest catalog.")
            ) {
                ProgressView()
                    .padding(.top, 8)
            }
        } else if case .error(let message) = viewModel.viewState, viewModel.products.isEmpty {
            statusSection(
                title: localized("Something Went Wrong"),
                systemImage: "exclamationmark.triangle",
                description: message
            ) {
                Button("Try Again") {
                    Task { await viewModel.refresh(showLoadingUI: true) }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        } else if viewModel.products.isEmpty {
            statusSection(
                title: emptyStateTitle,
                systemImage: emptyStateIcon,
                description: emptyStateDescription
            ) {
                if viewModel.isSearchActive {
                    Button("Clear Search") {
                        viewModel.searchQuery = ""
                        Task { await viewModel.applyFilters() }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }
        } else {
            productsSection
        }
    }

    private var emptyStateTitle: String {
        if viewModel.isSearchActive {
            return localized("No Results Found")
        }
        if viewModel.selectedCategory != "All" {
            return localized("No Products in Category")
        }
        return localized("No Products Yet")
    }

    private var emptyStateIcon: String {
        viewModel.isSearchActive ? "magnifyingglass" : "bag"
    }

    private var emptyStateDescription: String {
        if viewModel.isSearchActive {
            return localized("Try another keyword or clear your filters.")
        }
        if viewModel.selectedCategory != "All" {
            return localized("No products match the selected category.")
        }
        return localized("Pull to refresh or add a new product.")
    }

    private func statusSection<Actions: View>(
        title: String,
        systemImage: String,
        description: String,
        @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) -> some View {
        Section {
            VStack(spacing: 12) {
                ContentUnavailableView(title, systemImage: systemImage, description: Text(description))
                actions()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .listRowBackground(Color.clear)
        }
    }

    private var filtersSection: some View {
        Section {
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .onChange(of: viewModel.selectedCategory) { _, _ in
                HapticFeedback.play(.selection)
                Task { await viewModel.applyFilters() }
            }

            Picker("Sort", selection: $viewModel.sortOption) {
                Text("Title A-Z").tag(ProductSortOption.titleAscending)
                Text("Title Z-A").tag(ProductSortOption.titleDescending)
                Text("Price Low-High").tag(ProductSortOption.priceAscending)
                Text("Price High-Low").tag(ProductSortOption.priceDescending)
                Text("Top Rated").tag(ProductSortOption.ratingDescending)
            }
            .onChange(of: viewModel.sortOption) { _, _ in
                HapticFeedback.play(.selection)
                Task { await viewModel.applyFilters() }
            }
        }
    }

    private var productsSection: some View {
        Section {
            if viewModel.isSearching {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Searching…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.products) { product in
                Button {
                    viewModel.openDetail(productID: product.id)
                } label: {
                    ProductRowView(
                        product: product,
                        isFavorite: viewModel.isFavorite(productID: product.id),
                        onFavoriteTapped: {
                            viewModel.toggleFavorite(productID: product.id)
                        }
                    )
                }
                .buttonStyle(.plain)
                .onAppear {
                    Task { await viewModel.loadMoreIfNeeded(currentProduct: product) }
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }
}

struct ProductRowView: View {
    let product: Product
    let isFavorite: Bool
    let onFavoriteTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProductImageView(url: product.thumbnailURL)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(product.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline.bold())
            }

            Spacer()

            Button(action: onFavoriteTapped) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
