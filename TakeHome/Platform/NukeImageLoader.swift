//
//  NukeImageLoader.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation
import Nuke

final class NukeImageLoader: ImageLoadingProtocol, @unchecked Sendable {
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
