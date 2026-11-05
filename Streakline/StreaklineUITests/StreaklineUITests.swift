import XCTest

/// Launches the app into a Debug fixture and checks the screen that fixture is for.
///
/// Screenshots are attached to the result bundle. Set `STREAKLINE_SCREENSHOT_DIR` on the test
/// action to also write PNGs, for an App Store pass or a promo cut later.
@MainActor
final class StreaklineUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeFixtureShowsTheSeason() {
        let app = launch("home")
        let header = element("home.header", in: app)
        XCTAssertTrue(header.waitForExistence(timeout: 15))
        XCTAssertTrue(header.label.contains("Season 1"))
        XCTAssertTrue(header.label.contains("week 1 of 8"))
        XCTAssertTrue(header.label.contains("Week 1"))

        let plan = app.buttons["Plan nights"]
        XCTAssertTrue(plan.waitForExistence(timeout: 5))
        XCTAssertEqual(plan.value as? String, "8 pints left")

        let easyRun = app.buttons["workout.Day A"]
        XCTAssertTrue(easyRun.waitForExistence(timeout: 5))
        XCTAssertTrue(easyRun.label.contains("Easy run"))
        XCTAssertEqual(easyRun.value as? String, "Completed")
        capture(app, name: "home")
    }

    func testOnboardingFixtureShowsSetup() {
        let app = launch("onboarding")
        let title = app.staticTexts["Build a streak that helps"]
        XCTAssertTrue(title.waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["Your starting target"].exists)
        XCTAssertFalse(element("home.header", in: app).exists)
        capture(app, name: "onboarding")
    }

    func testProgressFixtureOpensProgress() {
        let app = launch("progress", extraArguments: ["-open-progress"])
        let month = element("progress.month", in: app)
        XCTAssertTrue(month.waitForExistence(timeout: 15))
        XCTAssertTrue(month.label.contains("This week vs week 1"))
        XCTAssertTrue(month.label.contains("Up 4.6 units from week 1."))
        XCTAssertTrue(month.label.contains("This is your log, not a health score."))
        let heading = app.staticTexts["How you earn XP"]
        if !heading.waitForExistence(timeout: 2) {
            app.swipeUp()
        }
        XCTAssertTrue(heading.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Badges"].exists)
        XCTAssertFalse(app.buttons["Share"].exists)
        capture(app, name: "progress")
    }

    func testSundaySealSharesACardAndWednesdayDoesNot() {
        XCUIDevice.shared.orientation = .portrait
        let sunday = launch("home", extraArguments: ["-ui-now", "2026-11-08T12:00:00Z"])
        XCTAssertTrue(element("home.header", in: sunday).waitForExistence(timeout: 15))
        let sealButton = sunday.buttons["Seal the week"]
        XCTAssertTrue(sealButton.waitForExistence(timeout: 5))
        sealButton.tap()

        XCTAssertTrue(sunday.staticTexts["1 of 3"].waitForExistence(timeout: 5) || labelContains("1 of 3", in: sunday))
        XCTAssertTrue(labelContains("2 of 10 pints", in: sunday))
        XCTAssertTrue(labelContains("not spent", in: sunday))
        XCTAssertTrue(labelContains("Missed", in: sunday))
        XCTAssertFalse(labelContains("XP", in: sunday))
        XCTAssertFalse(labelContains("Badge", in: sunday))

        element("week.seal.share", in: sunday).tap()
        let card = element("week.card", in: sunday)
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        XCTAssertEqual(
            card.label,
            "Streakline\nSeason 1\n1 of 3\n2 of 10 pints\nabout £44.00 not spent\nMissed\nstreakline.fit"
        )

        let shareCard = element("week.card.share", in: sunday)
        XCTAssertTrue(shareCard.waitForExistence(timeout: 5))
        shareCard.tap()
        let activity = sunday.otherElements["ActivityListView"]
        XCTAssertTrue(activity.waitForExistence(timeout: 8))
        if activity.buttons["Close"].exists {
            activity.buttons["Close"].tap()
        } else {
            sunday.swipeDown()
        }

        let drinks = sunday.switches["Include drinks"]
        XCTAssertTrue(drinks.waitForExistence(timeout: 5))
        drinks.tap()
        let hidden = NSPredicate(format: "label == %@", "Streakline\nSeason 1\n1 of 3\nMissed\nstreakline.fit")
        let hiddenCard = expectation(for: hidden, evaluatedWith: card)
        wait(for: [hiddenCard], timeout: 5)

        let wednesday = launch("home", extraArguments: ["-ui-now", "2026-11-04T12:00:00Z"])
        XCTAssertTrue(element("home.header", in: wednesday).waitForExistence(timeout: 15))
        XCTAssertFalse(wednesday.buttons["Seal the week"].exists)
    }

    func testHistorySharesAPastWeekAndNotTheOpenWeek() {
        XCUIDevice.shared.orientation = .portrait
        let app = launch("progress")
        XCTAssertTrue(element("home.header", in: app).waitForExistence(timeout: 15))
        app.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))

        app.staticTexts["Week 2"].tap()
        let share = element("week.seal.share", in: app)
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        share.tap()
        let card = element("week.card", in: app)
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        XCTAssertTrue(card.label.contains("Streakline"))
        XCTAssertTrue(card.label.contains("streakline.fit"))
        XCTAssertFalse(card.label.contains("week "))
        app.navigationBars["Share"].buttons["Close"].tap()
        let sealBar = app.navigationBars["Season 1, week 2 of 8"]
        XCTAssertTrue(sealBar.waitForExistence(timeout: 5))
        sealBar.buttons["Close"].tap()

        app.staticTexts["Week 3"].tap()
        XCTAssertTrue(app.staticTexts["Workout dates"].waitForExistence(timeout: 5))
        XCTAssertFalse(element("week.seal.share", in: app).exists)
        XCTAssertFalse(app.buttons["Share"].exists)
    }

    func testWorkoutFixtureOpensTheSession() {
        let app = launch("workout", extraArguments: ["-open-day", "Day A"])
        let mark = app.buttons["Mark as done"]
        XCTAssertTrue(mark.waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["Easy run"].exists)
        capture(app, name: "workout")
    }

    private func launch(_ fixture: String, extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-fixture", fixture] + extraArguments
        app.launch()
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func labelContains(_ text: String, in app: XCUIApplication) -> Bool {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.exists
    }

    private func capture(_ app: XCUIApplication, name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        guard let directory = ProcessInfo.processInfo.environment["STREAKLINE_SCREENSHOT_DIR"],
              !directory.isEmpty else { return }
        let folder = URL(fileURLWithPath: directory, isDirectory: true)
        let file = folder.appendingPathComponent("\(name).png")
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try shot.pngRepresentation.write(to: file)
        } catch {
            XCTFail("Could not write \(file.path): \(error.localizedDescription)")
        }
    }
}
