//
//  ImageLoadingProtocol.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

protocol ImageLoadingProtocol: Sendable {
    func prefetch(urls: [URL])
    func cancelPrefetch(urls: [URL])
}
