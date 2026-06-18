//
//  FavoritesModule.swift
//  TakeHome
//

import Foundation
import SwiftData

@MainActor
final class FavoritesModule {
    let fetchFavoritesUseCase: FetchFavoritesUseCase
    let toggleFavoriteUseCase: ToggleFavoriteUseCase

    private unowned let router: AppRouter
    private lazy var favoritesViewModel = FavoritesViewModel(
        fetchFavoritesUseCase: fetchFavoritesUseCase,
        toggleFavoriteUseCase: toggleFavoriteUseCase,
        router: router
    )

    init(infrastructure: AppInfrastructure, router: AppRouter) {
        self.router = router

        let productLocalDataSource = ProductLocalDataSource(
            modelContext: infrastructure.modelContainer.mainContext
        )
        let favoritesLocalDataSource = FavoritesLocalDataSource(
            modelContext: infrastructure.modelContainer.mainContext
        )
        let favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository(
            favoritesLocalDataSource: favoritesLocalDataSource,
            productLocalDataSource: productLocalDataSource
        )

        fetchFavoritesUseCase = FetchFavoritesUseCase(favoritesRepository: favoritesRepository)
        toggleFavoriteUseCase = ToggleFavoriteUseCase(favoritesRepository: favoritesRepository)
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        favoritesViewModel
    }
}
