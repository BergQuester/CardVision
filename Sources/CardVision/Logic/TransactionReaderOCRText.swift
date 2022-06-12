//
//  TransactionReaderOCRText.swift
//  Card Transactions
//
//  Created by Daniel Bergquist on 1/19/21.
//

import Foundation

typealias TransactionReaderOCRText = [String]

extension String {
    func isMatchedBy(regex: String) -> Bool {
        return (self.range(of: regex, options: .regularExpression) ?? nil) != nil
    }
}

extension TransactionReaderOCRText {
    func parseTransactions(screenshotDate: Date) -> [Transaction] {
        var ocrText = self

        var intermediateTransactions: [IntermediateTransaction] = []
        while let transaction = ocrText.nextTransaction() {
            intermediateTransactions.append(transaction)
        }

        return intermediateTransactions
            .map { $0.finalTransaction(screenshotDate: screenshotDate) }
    }
}

fileprivate extension Array where Element == String {
    static var debug: Bool { false }

    mutating func pop() -> Element? {
        guard let top = first else {
            return nil
        }

        remove(at: 0)
        return top
    }

    static func isDailyCashTransaction(payee: String, memo: String) -> Bool {
        // Non-daily cash payee
        let nonDailyCashPayees = ["Payment", "Daily Cash Adjustment", "Balance Adjustment"]

        guard !nonDailyCashPayees.contains(payee) else { return false }

        // Non-daily cash memos
        return !(memo.contains("Refund") || isDeclinedTransaction(declinedCandidate: memo))
    }

    static func isAmount(amountCandidate: String) -> Bool {
        amountCandidate.range(of: #"^\+*\$[\d,]*\.\d\d$"#, options: .regularExpression) != nil
    }

    static func isDeclinedTransaction(declinedCandidate: String) -> Bool {
        declinedCandidate.contains("Declined")
    }

    static func isPendingTransaction(pendingCandidate: String) -> Bool {
        pendingCandidate.contains("Pending")
    }

    // TODO: Refactor this to a better place
    mutating func nextTransaction() -> IntermediateTransaction? {
        if Self.debug {
            print(self.debugDescription)
        }

        guard var payee = pop() else {
            return nil
        }

        // Sometimes payee names get broken into additiona lines
        // Keep iterating until we find a valid transaction amount
        var foundAmount: String?
        while foundAmount == nil {

            guard let amountCandidate = pop() else { return nil }

            if Self.isAmount(amountCandidate: amountCandidate) {
                foundAmount = amountCandidate
            } else {
                payee += " \(amountCandidate)"
            }
        }

        guard let amount = foundAmount else { return nil }

        // Refunds have their own structure
        var foundMemo: String?
        var baTimeDescription: String?

        if payee == "Balance Adjustment" {
            guard let thirdBALine = pop() else { return nil }

            if thirdBALine == "Dispute - Provisional Adjustment" {
                foundMemo = thirdBALine
            } else {
                baTimeDescription = thirdBALine
                foundMemo = payee
            }
        } else {
            foundMemo = pop()
        }

        guard let memo = foundMemo else { return nil }

        // Not all transactions have daily cash rewards
        var dailyCash: String?

        if Self.isDailyCashTransaction(payee: payee, memo: memo) {
            repeat {
                dailyCash = pop()
            } while !(dailyCash?.contains { $0 == "%" } ?? true)
        }

        guard var timeDescription = baTimeDescription ?? pop() else { return nil }

        // sometimes "ago" ends up on the next line
        if timeDescription.contains("hour") && !timeDescription.contains("ago") {
            timeDescription = timeDescription + " " + (pop() ?? "")
        }
        // Attempt to remove family member's name from description when using Family Sharing.
        // ex. "NAME - Yesterday"
        if timeDescription.contains(" ") && !timeDescription.isMatchedBy(regex: "^[0-9]"){
            // If string contains spaces and does not start with a number.
            timeDescription = timeDescription
                .replacingOccurrences(of: "-", with: " ") // Remove the "-", sometimes it isn't picked up by OCR
                .split(separator: " ", maxSplits: 1)[1]   // Get everything after the first space
                .trimmingCharacters(in: .whitespaces)     // Trim whitespace
        }

        // Check if declined and pending
        let declined = Self.isDeclinedTransaction(declinedCandidate: memo)
        let pending = Self.isPendingTransaction(pendingCandidate: memo)

        if Self.debug {
            print("payee: \(payee)")
            print("amount: \(amount) is valid: \(Self.isAmount(amountCandidate: amount))")
            print("memo: \(memo)")
            print("dailyCash: \(dailyCash ?? "No cash")")
            print("timeDescription: \(timeDescription)")
            print("pending: \(pending)")
            print("declined: \(declined)")
            print("\n")
        }

        return IntermediateTransaction(timeDescription: timeDescription, payee: payee, amount: amount, dailyCash: dailyCash, memo: memo, pending: pending, declined: declined)
    }
}

struct IntermediateTransaction {

    /// The date of the transaction
    let timeDescription: String

    /// The payee (or payer)
    let payee: String

    /// The amount, in cents
    let amount: String

    /// The daily cash %
    let dailyCash: String?

    /// The memo for the transaction
    let memo: String

    /// If the transaction is pending
    let pending: Bool

    /// If the transaction was marked as declined
    let declined: Bool
}

extension IntermediateTransaction {
    func finalTransaction(screenshotDate: Date) -> Transaction {
        Transaction(date: parsedDate(screenshotDate: screenshotDate),        // TODO: Parse date
                    payee: payee,
                    amountInCents: amountInCents() ?? 0,    // FIXME: Handle bad result
                    dailyCash: dailyCashValue() ?? 0,       // FIXME: Handle bad result
                    memo: memo,
                    pending: pending,
                    declined: declined)
    }

    func amountInCents() -> Int? {
        let numbers = amount
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ".", with: "")

        guard let cents = Int(numbers) else { return nil }

        return amount.contains("+") ? cents : -cents
    }

    func dailyCashValue() -> Int? {
        guard let numbers = dailyCash?
            .replacingOccurrences(of: "%", with: "") else {
                return nil
            }

        return Int(numbers)
    }

    // FIXME: Pass in the actual date
    func parsedDate(screenshotDate: Date) -> Date {
        // Check Yesterday
        if timeDescription == "Yesterday" {
            return screenshotDate.date(byAddingDays: -1)
        }

        // Check weekday
        if let date = date(fromWeekDay: timeDescription, baseDate: screenshotDate) {
            return date
        }

        // Check %d/%m/%y format
        if let date = date(fromFormattedString: timeDescription) {
            return date
        }

        // Check for "X hours ago"
        if let date = date(fromHoursAgo: timeDescription, baseDate: screenshotDate) {
            return date
        }

        // Check for "x minutes ago"
        if let date = date(fromMinutesAgo: timeDescription, baseDate: screenshotDate) {
            return date
        }

        // Default to "just now"
        return screenshotDate
    }

    /// Attempts to find the most recent date matching the given day of the week
    /// - Parameters:
    ///   - timeDescription: The date description we are attempting to match
    ///   - baseDate: The date to start working back from
    /// - Returns: The matching date or nil if a date cannot be matched
    func date(fromWeekDay timeDescription: String, baseDate: Date) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"

        var offset = 0

        while offset <= 7 {
            let candidateDate = baseDate.date(byAddingDays: -offset)
            let candidateWeekday = dateFormatter.string(from: candidateDate)
            if timeDescription == candidateWeekday {

                return candidateDate
            }
            offset += 1
        }

        return nil
    }

    func date(fromFormattedString timeDescription: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.date(from: timeDescription)
    }

    func date(fromHoursAgo timeDescription: String, baseDate: Date) -> Date? {
        guard let hours = leadingValue(in: timeDescription, containing: "hour") else {
            return nil
        }

        return baseDate.date(byAddingHours: -hours)
    }

    func date(fromMinutesAgo timeDescription: String, baseDate: Date) -> Date? {
        guard let minutes = leadingValue(in: timeDescription, containing: "minute") else {
            return nil
        }

        return baseDate.date(byAddingHours: -minutes)
    }

    func leadingValue(in string: String, containing: String) -> Int? {
        guard timeDescription.contains(containing),
              let intValueString = timeDescription.split(separator: " ").first,
              let intValue = Int(intValueString) else {
            return nil
        }
        return intValue
    }
}
