//
//  AppInfrastructure.swift
//  TakeHome
//

import SwiftData
import Nuke

@MainActor
struct AppInfrastructure {
    let modelContainer: ModelContainer
    let imagePipeline: ImagePipeline
    let imageLoader: ImageLoadingProtocol
    let networkMonitor: NetworkMonitor

    init() {
        imagePipeline = ImagePipelineFactory.makeShared()
        ImagePipeline.shared = imagePipeline
        imageLoader = NukeImageLoader(pipeline: imagePipeline)
        networkMonitor = NetworkMonitor()

        do {
            modelContainer = try ModelContainer(
                for: ProductRecord.self, FavoriteRecord.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
