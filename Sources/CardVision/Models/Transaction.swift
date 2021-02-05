//
//  Transaction.swift
//  Card Transactions
//
//  Created by Daniel Bergquist on 1/18/21.
//

import Foundation

public struct Transaction {

    /// The date of the transaction
    public let date: Date

    /// The payee (or payer)
    public let payee: String

    /// The amount, in cents
    public let amountInCents: Int

    /// The daily cash %
    public let dailyCash: Int

    /// A memo for the transaction
    public let memo: String

    /// If the transaction is pending
    public let pending: Bool

    /// If the transaction was marked as declined
    public let declined: Bool

    fileprivate static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
}

public extension Array where Element == Transaction {
    var csvEntries: String {
        map { $0.csvEntry }.joined(separator: "\n")
    }

    var csvFileString: String {
        [Transaction.csvHeader, csvEntries].joined(separator: "\n")
    }

    var csvData: Data? {
        csvFileString.data(using: .utf8)
    }

    func filtered(isPending: Bool) -> [Element] {
        filter { $0.pending == isPending}
    }

    func filtered(isDeclined: Bool) -> [Element] {
        filter { $0.declined == isDeclined}
    }
}

public extension Transaction {
    static var csvHeader: String {
        "Date,Payee,Amount,DailyCash,Memo,Pending,Declined"
    }

    var csvEntry: String {
        let values: [String] = [formattedDate, formattedPayee, formattedAmount, formattedDailyCash, formattedDescription, "\(pending)", "\(declined)"]

        return values.joined(separator: ",")
    }

    internal var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }

    internal var formattedPayee: String {
        payee.commasStriped
    }

    internal var formattedAmount: String {
        "\(formattedDollarAmount).\(formattedCentAmount)"
    }

    internal var formattedDollarAmount: String {
        "\(amountInCents / 100)"
    }

    internal var formattedCentAmount: String {
        let cents = abs(amountInCents) % 100
        return String(format: "%02d", cents)
    }

    internal var formattedDailyCash: String {
        "\(dailyCash)"
    }

    internal var formattedDescription: String {
        memo.commasStriped
    }
}

fileprivate extension String {
    var commasStriped: String {
        self.replacingOccurrences(of: ",", with: "")
    }
}
