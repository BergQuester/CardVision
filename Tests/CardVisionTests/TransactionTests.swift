//
//  TransactionTests.swift
//  
//
//  Created by Alex Wolfe on 6/12/22.
//

import XCTest
@testable import CardVision

final class TransactionTests: XCTestCase {
    var ocrText:[String]!
    var date:Date!
    override func setUp() {
        super.setUp()
        // TODO: Mock current date in Swift to make it easier to compare
        date = Date()
        ocrText = [
            "Grocery Store", "$80.25", "Somewhere, USA", "2%", "15 minutes ago",
            "Grocery Store", "$101.99", "Somewhere, USA", "2%", "2 hours ago",
            "Convenience Store", "$9.92", "Somewhere, USA", "1%", "Yesterday",
            // TODO: Test additional dates after mocking a static date.
        ]
    }
    
    func testTransactionDates() {
        let transactions = ocrText.parseTransactions(screenshotDate: Date())
        debugPrint(transactions)
        XCTAssertEqual(transactions.count, ocrText.count / 5, "Transactions should equal the length of ocrText/5")
        // FIXME: Without a mocked date, these tests will break until at least 2 hours after midnight.
        assert(Calendar.current.isDate(date, inSameDayAs: transactions[0].date))
        assert(Calendar.current.isDate(date, inSameDayAs: transactions[1].date))
        assert(Calendar.current.isDate(date.date(byAddingDays: -1), inSameDayAs: transactions[2].date))
        // TODO: Test additional dates after mocking a static date.
    }
    
    func testTransactionDatesFamilySharing() {
        for i in 0...ocrText.count-1 { // modify ocrText array to prepend "Partner" to timestamps
            if (i+1) % 5 == 0 {
                if (i+1) % 10 == 0 { ocrText[i] = "Partner " + ocrText[i] } // OCR sometimes doesn't pick up on -
                else { ocrText[i] = "Partner - " + ocrText[i] }
                debugPrint(ocrText[i])
            }
        }
        
        let transactions = ocrText.parseTransactions(screenshotDate: Date())
        // FIXME: Without a mocked date, these tests will break until at least 2 hours after midnight.
        assert(Calendar.current.isDate(date, inSameDayAs: transactions[0].date))
        assert(Calendar.current.isDate(date, inSameDayAs: transactions[1].date))
        assert(Calendar.current.isDate(date.date(byAddingDays: -1), inSameDayAs: transactions[2].date))
        // TODO: Test additional dates after mocking a static date.
    }
    
    static var allTests = [(
        "testTransactionDates", testTransactionDates,
        "testTransactionDatesFamilySharing", testTransactionDatesFamilySharing
    )]
}

