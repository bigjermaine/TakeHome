import SwiftUI

struct FavoritesFlowView: View {
    let container: DIContainer
    @ObservedObject var viewModel: FavoritesViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.favoritesPath) {
            FavoritesView(viewModel: viewModel)
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

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @Environment(\.locale) private var locale

    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Something Went Wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if viewModel.favorites.isEmpty {
                ContentUnavailableView(
                    "No favorites yet",
                    systemImage: "heart",
                    description: Text("Products you favorite will appear here.")
                )
            } else {
                List(viewModel.favorites) { product in
                    Button {
                        viewModel.openDetail(productID: product.id)
                    } label: {
                        HStack(spacing: 12) {
                            ProductImageView(url: product.thumbnailURL)
                                .frame(width: 56, height: 56)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.headline)
                                Text(product.price, format: .currency(code: "USD"))
                                    .font(.subheadline)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.remove(product: product)
                        } label: {
                            Label("Remove", systemImage: "heart.slash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.load()
        }
        .overlay(alignment: .bottom) {
            if let undoAction = viewModel.undoAction {
                UndoBanner(
                    message: String(
                        format: AppLocalization.string("Removed %@", locale: locale),
                        undoAction.product.title
                    ),
                    actionTitle: AppLocalization.string("Undo", locale: locale)
                ) {
                    viewModel.undoRemove()
                }
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel.undoAction)
    }
}

struct UndoBanner: View {
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .lineLimit(1)
            Spacer()
            Button(actionTitle, action: action)
                .fontWeight(.semibold)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 8, y: 4)
    }
}
