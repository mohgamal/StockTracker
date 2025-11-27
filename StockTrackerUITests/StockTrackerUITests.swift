//
//  StockTrackerUITests.swift
//  StockTrackerUITests
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import XCTest

final class StockTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    @MainActor
    func testAppLaunches() {
        let startButton = app.buttons["StartButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testConnectionStatusIndicatorExists() {
        let statusText = app.staticTexts["ConnectionStatusText"]
        XCTAssertTrue(statusText.waitForExistence(timeout: 5))
    }

    @MainActor
    func testStartStopButton() {
        let startButton = app.buttons["StartButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        startButton.tap()

        let stopButton = app.buttons["StopButton"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 5))

        stopButton.tap()

        let startButtonAgain = app.buttons["StartButton"]
        XCTAssertTrue(startButtonAgain.waitForExistence(timeout: 5))
    }

    @MainActor
    func testStockListDisplays() {
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.exists)
    }

    @MainActor
    func testStockSymbolsExist() {
        let appleCell = app.staticTexts["StockSymbol_AAPL"]
        XCTAssertTrue(appleCell.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigationToDetailView() {
        let appleCell = app.staticTexts["StockSymbol_AAPL"]
        XCTAssertTrue(appleCell.waitForExistence(timeout: 5))

        appleCell.tap()

        let detailTitle = app.navigationBars["AAPL"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 5))
    }

    @MainActor
    func testDetailViewShowsCurrentPrice() {
        let appleCell = app.staticTexts["StockSymbol_AAPL"]
        XCTAssertTrue(appleCell.waitForExistence(timeout: 5))

        appleCell.tap()

        let currentPriceLabel = app.staticTexts["Current Price"]
        XCTAssertTrue(currentPriceLabel.waitForExistence(timeout: 3))
    }

    @MainActor
    func testDetailViewShowsAboutSection() {
        let appleCell = app.staticTexts["StockSymbol_AAPL"]
        XCTAssertTrue(appleCell.waitForExistence(timeout: 5))

        appleCell.tap()

        let aboutLabel = app.staticTexts["About"]
        XCTAssertTrue(aboutLabel.waitForExistence(timeout: 3))
    }

    @MainActor
    func testBackNavigationFromDetailView() {
        let appleCell = app.staticTexts["StockSymbol_AAPL"]
        XCTAssertTrue(appleCell.waitForExistence(timeout: 5))

        appleCell.tap()

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))

        backButton.tap()

        let startButton = app.buttons["StartButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
