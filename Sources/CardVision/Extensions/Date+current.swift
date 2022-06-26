//
//  Date+current.swift
//  
//  Implements a Date.current method to get the current date in a way that can be mocked for testing.
//  Adapted from: https://dev.to/ivanmisuno/deterministic-unit-tests-for-current-date-dependent-code-in-swift-2h72
//  Created by Alex Wolfe on 6/18/22.
//

import Foundation


internal var __date_currentImpl = { Date() }

extension Date {
    /// Return current date
    /// Please note that use of `Date()`  and  `Date(timeIntervalSinceNow:)` should not be prohibited
    /// through lint rules or commit hooks, always use `Date.current`
    static var current: Date {
        return __date_currentImpl()
    }
}
