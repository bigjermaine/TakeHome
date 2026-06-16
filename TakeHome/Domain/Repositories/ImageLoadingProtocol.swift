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
