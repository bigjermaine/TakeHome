import SwiftUI

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductDetailViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let product):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ProductImageView(url: product.thumbnailURL, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)

                        if !product.imageURLs.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(product.imageURLs, id: \.absoluteString) { url in
                                        ProductImageView(url: url)
                                            .frame(width: 88, height: 88)
                                    }
                                }
                            }
                        }

                        Text(product.title)
                            .font(.title2.bold())

                        HStack {
                            Text(product.price, format: .currency(code: "USD"))
                                .font(.title3.bold())
                            Spacer()
                            Label(String(format: "%.1f", product.rating), systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                        }

                        Label(product.category, systemImage: "tag")
                        Label(product.brand, systemImage: "building.2")
                        Label(
                            String(
                                format: AppLocalization.string("Stock: %lld", locale: locale),
                                Int64(product.stock)
                            ),
                            systemImage: "shippingbox"
                        )

                        if product.isLocalOnly {
                            Text("Local product")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.orange.opacity(0.15))
                                .clipShape(Capsule())
                        }

                        Text(product.productDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            case .error(let messageKey):
                ContentUnavailableView(
                    "Unable to load product",
                    systemImage: "exclamationmark.triangle",
                    description: Text(AppLocalization.string(messageKey, locale: locale))
                )
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? .red : .primary)
                }

                Button("Edit") {
                    HapticFeedback.play(.light)
                    viewModel.openEditor()
                }

                Button(role: .destructive) {
                    HapticFeedback.play(.warning)
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete this product?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                HapticFeedback.play(.heavy)
                Task {
                    if await viewModel.deleteProduct() {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task { await viewModel.load() }
        }
        .onChange(of: router.productPath.count) { oldCount, newCount in
            if newCount < oldCount {
                Task { await viewModel.load() }
            }
        }
    }
}

struct ProductEditorView: View {
    @ObservedObject var viewModel: ProductEditorViewModel
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Title", text: $viewModel.title)
                TextField("Description", text: $viewModel.productDescription, axis: .vertical)
                TextField("Category", text: $viewModel.category)
                TextField("Brand", text: $viewModel.brand)
            }

            Section("Pricing & Inventory") {
                TextField("Price", text: $viewModel.price)
                    .keyboardType(.decimalPad)
                TextField("Stock", text: $viewModel.stock)
                    .keyboardType(.numberPad)
                TextField("Rating", text: $viewModel.rating)
                    .keyboardType(.decimalPad)
            }

            Section("Image") {
                TextField("Thumbnail URL", text: $viewModel.thumbnailURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if case .error(let messageKey) = viewModel.viewState {
                Section {
                    Text(AppLocalization.string(messageKey, locale: locale))
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditingExisting ? "Edit Product" : "Add Product")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    HapticFeedback.play(.light)
                    Task {
                        if await viewModel.save() {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.viewState == .saving)
            }
        }
        .overlay {
            if viewModel.viewState == .loading || viewModel.viewState == .saving {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
