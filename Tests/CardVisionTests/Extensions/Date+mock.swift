//
//  Date+mock.swift
//  
//  Overrides the current date to the set mockDate.
//  Adapted from: https://dev.to/ivanmisuno/deterministic-unit-tests-for-current-date-dependent-code-in-swift-2h72
//  Created by Alex Wolfe on 6/18/22.
//

import Foundation
@testable import CardVision

// Mock current date to simplify testing
extension Date {
    
    // Monday, January 1, 2018 12:00:00 PM UTC
    static var mockDate: Date = Date(timeIntervalSinceReferenceDate: 536500800)

    static func overrideCurrentDate(_ currentDate: @autoclosure @escaping () -> Date) {
            __date_currentImpl = currentDate
    }
}
