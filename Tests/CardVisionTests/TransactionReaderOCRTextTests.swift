//
//  TransactionReaderOCRTextTests.swift
//  
//
//  Created by Alex Wolfe on 6/12/22.
//

import XCTest
@testable import CardVision

final class TransactionReaderOCRTextTests: XCTestCase {
    
    var ocrText:[String]!
    
    override func setUp() {
        super.setUp()
        
        // mockDate is Monday, January 1, 2018 12:00:00 PM UTC
        Date.overrideCurrentDate(Date.mockDate)
        ocrText = [
            "Transaction 1", "$111.11", "Pending", "Card Number Used", "2%", "15 minutes", "ago", // test extra splitting on "ago"
            "Transaction 2", "$222.22", "Somewhere, USA", "2%", "2 hours ago",
            "Transaction 3", "$333.33", "Somewhere, USA", "1%", "Monday", // Monday resolves to the current day in these tests, (However, it would not be used to describe current day in Apple Wallet.)
            "Transaction 4", "$444.44", "Somewhere, USA", "1%", "Yesterday",
            "Transaction 5", "$555.55", "Somewhere, USA", "1%", "Saturday",
            "Transaction 6", "$666.66", "Somewhere, USA", "1%", "Friday",
            "Transaction 7", "$777.77", "Somewhere, USA", "1%", "Thursday",
            "Transaction 8", "$888.88", "Somewhere, USA", "1%", "Wednesday",
            "Transaction 9", "$999.99", "Somewhere, USA", "1%", "Tuesday",
            "Transaction 10", "$1000.00", "Somewhere, USA", "1%", "12/25/2017",
        ]
        
    }
    
    
    func testTransactionText() {
        let transactions = ocrText.parseTransactions(screenshotDate: Date.current)
        verifyTransactionDates(transactions: transactions)
        
        // Verify the memo of each transaction:
        XCTAssertEqual("Pending", transactions[0].memo)
        let expectedMemo = "Somewhere, USA"
        for i in 1...transactions.count-1 {
            XCTAssertEqual(expectedMemo, transactions[i].memo)
        }
    }
    
    /// Verifies transaction parsing when using family sharing with variations on how the partner name is parsed.
    func testTransactionTextFamilySharing() {
        ocrText = [
            "Transaction 1", "$111.11", "Pending", "Card Number Used", "2%", "Partner - 15 minutes", "ago", // test extra splitting on "ago"
            "Transaction 2", "$222.22", "Somewhere, USA", "2%", "Partner", "2 hours ago",  // Separate partner field
            "Transaction 3", "$333.33", "Somewhere, USA", "1%", "Partner - Monday", // with dash
            "Transaction 4", "$444.44", "Somewhere, USA", "1%", "Partner • Yesterday", // with dot instead of dash
            "Transaction 5", "$555.55", "Somewhere, USA", "1%", "Partner Saturday", // no separator
            "Transaction 6", "$666.66", "Somewhere, USA", "1%", "Partner - Friday",
            "Transaction 7", "$777.77", "Somewhere, USA", "1%", "-", "Partner Thursday", // extra dash before
            "Transaction 8", "$888.88", "Somewhere, USA", "1%", "Partner", "Wednesday",
            "Transaction 9", "$999.99", "Somewhere, USA", "1%", "-", "Partner", "Tuesday", //extra dash before and separator
            "Transaction 10", "$1000.00", "Somewhere, USA", "1%", "Partner", "12/25/2017"
        ]
        let transactions = ocrText.parseTransactions(screenshotDate: Date.current)
        verifyTransactionDates(transactions: transactions)
        
        // Verify the memo of each transaction:
        XCTAssertEqual("Partner - Pending", transactions[0].memo)
        let expectedMemo = "Partner - Somewhere, USA"
        for i in 1...transactions.count-1 {
            XCTAssertEqual(expectedMemo, transactions[i].memo)
        }
    }
    
    /// Helper method to make sure that the default transaction dates are correct.
    func verifyTransactionDates(transactions: [Transaction]) {
        XCTAssertEqual(Date.current.date(byAddingMinutes: -15), transactions[0].date)
        XCTAssertEqual(Date.current.date(byAddingHours: -2), transactions[1].date)
        XCTAssertEqual(Date.current, transactions[2].date)
        for i in 3...transactions.count-1 {
            let daysAgo = 2-i
            XCTAssert(Calendar.current.isDate(Date.current.date(byAddingDays: daysAgo), inSameDayAs: transactions[i].date))
        }
        
    }
    
    static var allTests = [(
        "testTransactionText", testTransactionText,
        "testTransactionTextFamilySharing", testTransactionTextFamilySharing
    )]
}
