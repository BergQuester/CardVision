//
//  APImage.swift
//  Card Transactions (iOS)
//
//  Created by Daniel Bergquist on 1/17/21.
//

import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
public typealias APImage = UIImage

public extension UIImage {
    convenience init?(contentsOf url: URL) {
        self.init(contentsOfFile: url.absoluteString)
    }
}

public extension Image {
    init(apImage: APImage) {
        self.init(uiImage: apImage)
    }
}

#elseif os(macOS)
public typealias APImage = NSImage

public extension NSImage {
    var cgImage: CGImage? {
        var imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let imageRef = cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        return imageRef
    }
}

public extension Image {
    init(apImage: APImage) {
        self.init(nsImage: apImage)
    }
}
#endif
