//
//  Date+Math.swift
//  Card Transactions
//
//  Created by Daniel Bergquist on 1/20/21.
//

import Foundation

extension Date {
    func date(byAddingDays days: Int) -> Date {
        var components = DateComponents()
        components.day = days
        return date(byAddingComponent: components)
    }

    func date(byAddingHours hours: Int) -> Date {
        var components = DateComponents()
        components.hour = hours
        return date(byAddingComponent: components)
    }

    func date(byAddingMinutes minutes: Int) -> Date {
        var components = DateComponents()
        components.minute = minutes
        return date(byAddingComponent: components)
    }

    func date(byAddingComponent component: DateComponents) -> Date {
        Calendar.current.date(byAdding: component, to: self)!
    }
}
