//
//  TransactionImage.swift
//  Card Transactions (iOS)
//
//  Created by Daniel Bergquist on 1/17/21.
//

import Foundation
import CoreImage

public struct TransactionImage {
    /// The location of the file
    public let imageURL: URL

    /// The loaded image
    public var image: APImage

    /// Creation Date
    public var creationDate: Date

    /// Read transactions
    public var transactions: [Transaction] = []
}

public extension TransactionImage {
    init?(withURL url: URL) {

        guard let data = try? Data(contentsOf: url),
              let image = APImage(data: data) else {
            return nil
        }

        let urlCreationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        creationDate = urlCreationDate ?? Date()

        imageURL = url
        self.image = image
    }

    mutating func read() {
        guard let cgImage = image.cgImage else { return }

        var readText: TransactionReaderOCRText?

        let readGroup = DispatchGroup()
        readGroup.enter()

        TransactionReaderOCR.read(image: cgImage) { result in
            switch result {
            case .success(let recognizedStrings):
                readText = recognizedStrings
            default:
                break
            }
            readGroup.leave()
        }

        readGroup.wait()

        transactions = readText?.parseTransactions(screenshotDate: creationDate) ?? []
    }

    static func read(image: TransactionImage) -> TransactionImage {
        var image = image
        image.read()
        return image
    }
}

extension Array where Element == TransactionImage {
    func arrayFromReading() -> [TransactionImage] {
        // TODO: Run in parallel?
        map(TransactionImage.read(image:))
    }

    public func allTransactions() -> [Transaction] {
        arrayFromReading()
            .map { $0.transactions }
            .reduce([]) { $0 + $1 }
            .sorted { $0.date < $1.date }
    }
}
