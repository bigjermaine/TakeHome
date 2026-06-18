//
//  NukeImageLoader.swift
//  TakeHome
//

import Foundation
import Nuke

actor NukeImageLoader: ImageLoadingProtocol {
    private let prefetcher: ImagePrefetcher

    init(pipeline: ImagePipeline = .shared) {
        prefetcher = ImagePrefetcher(pipeline: pipeline)
    }

    func prefetch(urls: [URL]) {
        prefetcher.startPrefetching(with: urls)
    }

    func cancelPrefetch(urls: [URL]) {
        prefetcher.stopPrefetching(with: urls)
    }
}

enum ImagePipelineFactory {
    static func makeShared() -> ImagePipeline {
        var configuration = ImagePipeline.Configuration()
        configuration.dataCache = try? DataCache(name: "com.takehome.TakeHome.images")
        return ImagePipeline(configuration: configuration)
    }
}
