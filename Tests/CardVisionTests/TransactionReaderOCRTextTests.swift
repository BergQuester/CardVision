//
//  TransactionTests.swift
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
            "Transaction 1", "$111.11", "Somewhere, USA", "2%", "15 minutes ago",
            "Transaction 2", "$222.22", "Somewhere, USA", "2%", "2 hours ago",
            "Transaction 3", "$333.33", "Somewhere, USA", "1%", "Monday", // Monday resolves to the current day (Monday, would not be used to describe current day in Apple Wallet.
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
        let expectedMemo = "Somewhere, USA"
        for transaction in transactions {
            XCTAssertEqual(expectedMemo, transaction.memo)
        }
    }
    
    func testTransactionTextFamilySharing() {
        for i in 0...ocrText.count-1 { // modify ocrText array to prepend "Partner" to timestamps
            if (i+1) % 5 == 0 {
                if (i+1) % 10 == 0 { ocrText[i] = "Partner " + ocrText[i] } // OCR sometimes doesn't pick up on the "-"
                else { ocrText[i] = "Partner - " + ocrText[i] }
            }
        }
        let transactions = ocrText.parseTransactions(screenshotDate: Date.current)
        verifyTransactionDates(transactions: transactions)
        
        // Verify the memo of each transaction:
        let expectedMemo = "Partner - Somewhere, USA"
        for transaction in transactions {
            XCTAssertEqual(expectedMemo, transaction.memo)
        }
    }
    
    func verifyTransactionDates(transactions: [Transaction]) {
        // Helper method to make sure that the transaction dates are correct.
        XCTAssertEqual(transactions.count, ocrText.count / 5, "Transactions should equal the length of ocrText/5")
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
