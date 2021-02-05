//
//  TransactionReaderOCR.swift
//  Card Transactions
//
//  Created by Daniel Bergquist on 1/5/21.
//

import Vision

struct TransactionReaderOCR {

    typealias ReadResult = (Result<TransactionReaderOCRText, Error>) -> Void

    // Get the CGImage on which to perform requests.
    static func read(image: CGImage, completionHandler: ReadResult?) {

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: image)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completionHandler?(.failure(error))
                return
            }

            let results = recognizeTextHandler(request: request)
            completionHandler?(.success(results))
        }

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            completionHandler?(.failure(error))
        }
    }

    static func recognizeTextHandler(request: VNRequest) -> [String] {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return []
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }

        return recognizedStrings
    }
}
