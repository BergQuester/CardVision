//
//  File.swift
//  
//
//  Created by Daniel Bergquist on 2/7/21.
//

// This is a quick and dirty commandline tool for processing Apple card screenshots
// using CardVision. Pull requests welcome.

import Foundation
import CardVision

// Commandline argument keys
let imagePathKey = "imagePath"
let outputPathKey = "outputPath"

// Fetch commandline arguments
let defaults = UserDefaults.standard
guard let imagePath = defaults.string(forKey: imagePathKey) else {
    print("error: no \(imagePathKey) set")
    printHelp()
    exit(-1)
}
guard let outputPath = defaults.string(forKey: outputPathKey) else {
    print("error: no \(outputPathKey) defined")
    printHelp()
    exit(-1)
}

// process images
let csvData = FileManager()
    .images(inPath: imagePath)
    .allTransactions()
    .filtered(isDeclined: false)
    .csvData

// Output
let outputURL = URL(fileURLWithPath: outputPath)
do {
    try csvData?.write(to: outputURL)
} catch {
    print("\(error)")
    exit(-1)
}



/// Prints commandline help
func printHelp() {
    let help =
"""
cardvision -\(imagePathKey) <path_to_cropped_images> -\(outputPathKey) <path_to_output_file>
"""

    print(help)
}
