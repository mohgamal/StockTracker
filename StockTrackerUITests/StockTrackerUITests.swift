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
        XCTAssertTrue(app.buttons["Start"].exists)
    }

    @MainActor
    func testConnectionStatusIndicatorExists() {
        let disconnectedText = app.staticTexts["Disconnected"]
        XCTAssertTrue(disconnectedText.exists)
    }

    @MainActor
    func testStartStopButton() {
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists)

        startButton.tap()

        let stopButton = app.buttons["Stop"]
        XCTAssertTrue(stopButton.exists)

        stopButton.tap()

        XCTAssertTrue(app.buttons["Start"].exists)
    }

    @MainActor
    func testStockListDisplays() {
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.exists)
    }

    @MainActor
    func testStockSymbolsExist() {
        let appleCell = app.staticTexts["AAPL"]
        XCTAssertTrue(appleCell.waitForExistence(timeout: 2))
    }

    @MainActor
    func testNavigationToDetailView() {
        let appleCell = app.staticTexts["AAPL"].firstMatch
        XCTAssertTrue(appleCell.waitForExistence(timeout: 2))

        appleCell.tap()

        let detailTitle = app.navigationBars["AAPL"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 2))
    }

    @MainActor
    func testDetailViewShowsCurrentPrice() {
        let appleCell = app.staticTexts["AAPL"].firstMatch
        XCTAssertTrue(appleCell.waitForExistence(timeout: 2))

        appleCell.tap()

        let currentPriceLabel = app.staticTexts["Current Price"]
        XCTAssertTrue(currentPriceLabel.exists)
    }

    @MainActor
    func testDetailViewShowsAboutSection() {
        let appleCell = app.staticTexts["AAPL"].firstMatch
        XCTAssertTrue(appleCell.waitForExistence(timeout: 2))

        appleCell.tap()

        let aboutLabel = app.staticTexts["About"]
        XCTAssertTrue(aboutLabel.exists)
    }

    @MainActor
    func testBackNavigationFromDetailView() {
        let appleCell = app.staticTexts["AAPL"].firstMatch
        appleCell.tap()

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.exists)

        backButton.tap()

        XCTAssertTrue(app.buttons["Start"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
