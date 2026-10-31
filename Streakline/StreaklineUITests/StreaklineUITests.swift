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
        capture(app, name: "progress")
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
