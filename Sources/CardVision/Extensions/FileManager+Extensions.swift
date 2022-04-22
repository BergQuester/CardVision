//
//  FileManager+Extensions.swift
//  Card Transactions (iOS)
//
//  Created by Daniel Bergquist on 1/17/21.
//

import Foundation

extension FileManager {
    public func images(inPath: String) -> [TransactionImage] {
        let manager = FileManager()

        do {
            let images = try manager.contentsOfDirectory(atPath: inPath)
                .filter(isImage(_:))
                .map { inPath + "/" + $0 }
                .compactMap(loadImage(_:))
            return images
        } catch {
            print(error.localizedDescription)
        }
        return []
    }

    func isImage(_ path: String) -> Bool {
        let result = ["jpeg", "jpg", "png"]
            .reduce(false) {acc, item in
                return acc || path.lowercased().hasSuffix(item)
            }

        return result
    }

    func loadImage(_ path: String) -> TransactionImage? {
        let url = URL(fileURLWithPath: path)
        return TransactionImage(withURL: url)
    }
}
