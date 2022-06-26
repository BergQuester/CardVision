//
//  String+isMatchedBy.swift
//  
//
//  Created by Alex Wolfe on 6/26/22.
//

import Foundation

extension String {
    /// Returns whether the string matches the given regular expression
    func isMatchedBy(regex: String) -> Bool {
        return (self.range(of: regex, options: .regularExpression) ?? nil) != nil
    }
}
