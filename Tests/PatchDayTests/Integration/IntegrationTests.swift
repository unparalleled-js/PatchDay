//
//  File.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/24/20.

import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

// swiftlint:disable function_body_length
class IntegrationTests: XCTestCase {
#if targetEnvironment(simulator)

    private var sdk = PatchData()
    private let dummyViewController = UIViewController()

    override func setUp() {
        sdk.resetAll()
    }

    func beforeEach() {
        sdk.resetAll()
    }

    // MARK: - ADD INTEGRATION TESTS HERE

    var tests: [() -> Void] {
        [
            whenTakingHormoneFromActionAlert_setsNotificationWithUpdatedDate,
            whenChangingHormoneBadge_updatesCorrectly,
            whenContinuingOnChangeDeliveryMethodAlert_addsOrRemoveHormonesToGetToDefaultQuantity,
            cyclesThroughPillExpirationIntervalXDaysOnXDaysOffCorrectly
        ]
    }

    // MARK: - Synchronous Test Runner

    func test_runAll() {
        for test in tests {
            beforeEach()
            test()
        }
    }

    // MARK: - Integration Test Implementations

    func whenChangingHormoneBadge_updatesCorrectly() {
        let badge = PDBadge(sdk: sdk)
        sdk.settings.setDeliveryMethod(to: .Patches)  // Should trigger reset to 3 patches
        let ids = self.sdk.hormones.all.map({ $0.id })
        if ids.count < 3 {
            XCTFail("Hormone count does not match delivery method")
            return
        }
        sdk.hormones.setDate(by: ids[0], with: DateFactory.createDate(daysFromNow: -20)!)
        sdk.hormones.setDate(by: ids[1], with: DateFactory.createDate(daysFromNow: -20)!)
        sdk.hormones.setDate(by: ids[2], with: DateFactory.createDate(daysFromNow: -20)!)
        badge.reflect()

        XCTAssertEqual(3, sdk.hormones.totalExpired)
        XCTAssertEqual(3, badge.value)

        sdk.hormones.setDate(at: 0, with: Date())
        badge.reflect()

        XCTAssertEqual(2, sdk.hormones.totalExpired)
        XCTAssertEqual(2, badge.value)
    }

    func whenContinuingOnChangeDeliveryMethodAlert_addsOrRemoveHormonesToGetToDefaultQuantity() {
        let tabs = TabReflector(
            tabBarController: UITabBarController(),
            viewControllers: [UIViewController()],
            sdk: sdk
        )
        let handlers = DeliveryMethodMutationAlertActionHandler { (_, _) in () }
        let patchesToGelAlert = DeliveryMethodMutationAlert(
            sdk: sdk,
            tabs: tabs,
            originalDeliveryMethod: .Patches,
            originalQuantity: sdk.settings.quantity.rawValue,
            newDeliveryMethod: .Gel,
            handlers: handlers
        )
        patchesToGelAlert.continueHandler()
        XCTAssertEqual(1, sdk.hormones.count)
        XCTAssertEqual(1, sdk.settings.quantity.rawValue)

        let injectionsToPatchesAlert = DeliveryMethodMutationAlert(
            sdk: sdk,
            tabs: tabs,
            originalDeliveryMethod: .Injections,
            originalQuantity: 4,
            newDeliveryMethod: .Patches,
            handlers: handlers
        )
        injectionsToPatchesAlert.continueHandler()
        XCTAssertEqual(3, sdk.hormones.count)
        XCTAssertEqual(3, sdk.settings.quantity.rawValue)
    }

    /// PillExpiraionInterval XDaysOnXdaysOff test.
    /// This is a particularly complex schedule that warrants its own integration test.
    func cyclesThroughPillExpirationIntervalXDaysOnXDaysOffCorrectly() {
        let dependencies = MockDependencies()
        dependencies.sdk = sdk
        let now = MockNow()
        let tableView = UITableView()
        let alertFactory = AlertFactory(sdk: sdk, tabs: dependencies.tabs)
        let mockPillsTable = MockPillsTable()
        let listViewModel = PillsViewModel(
            pillsTableView: tableView,
            alertFactory: alertFactory,
            table: mockPillsTable,
            dependencies: dependencies
        )

        // Create new pill from the Pills View.
        listViewModel.goToNewPillDetails(pillsViewController: dummyViewController)
        let expectedCount = 3

        // Verify new pill was created - 2 defaults + 1 new one
        XCTAssertEqual(expectedCount, sdk.pills.count)

        // Initial details viewModel
        let newIndex = expectedCount - 1
        var detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)

        // Select expiration interval of .XDaysOnXDaysOff
        let intervalOptions = PillStrings.Intervals.all
        guard let indexToSelect = intervalOptions.firstIndex(
            where: { $0 == PillStrings.Intervals.XDaysOnXDaysOff }
        ) else {
            XCTFail("Unable to select .XDaysOnXDaysOff")
            return
        }
        detailsViewModel.selectExpirationInterval(indexToSelect)
        XCTAssertEqual(.XDaysOnXDaysOff, detailsViewModel.expirationInterval)
        XCTAssertEqual("Days on:", detailsViewModel.daysOneLabelText)
        XCTAssertEqual("Days off:", detailsViewModel.daysTwoLabelText)

        // Select 3 days on and 3 days off
        detailsViewModel.selectFromDaysPicker(2, daysNumber: 1)
        detailsViewModel.selectFromDaysPicker(2, daysNumber: 2)
        XCTAssertEqual("3", detailsViewModel.daysOn)
        XCTAssertEqual("3", detailsViewModel.daysOff)
        detailsViewModel.save()

        // Take pill - Day 1
        listViewModel.takePill(at: newIndex)

        // Check that the current position is reflected in the view model
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 2 of 3 (on)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        // Fast forward to tomorrow
        guard let tomorrow = DateFactory.createDate(daysFromNow: 1) else {
            XCTFail("Unable to create tomorrow date.")
            return
        }
        now.now = tomorrow
        let pillSchedule = sdk.pills as! PillSchedule
        pillSchedule._now = now
        for swallowable in pillSchedule.all {
            let pill = swallowable as! Pill
            pill._now = now
        }
        sdk.pills.awaken()
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)

        // Verify the new day and the same position
        XCTAssertEqual(0, detailsViewModel.pill!.timesTakenToday)
        XCTAssertEqual("Current position: 2 of 3 (on)", detailsViewModel.daysPositionText)

        // Take again - Day 2
        listViewModel.takePill(at: newIndex)
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 3 of 3 (on)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)
    }

    func whenTakingHormoneFromActionAlert_setsNotificationWithUpdatedDate() {
        guard let hormone = sdk.hormones[0] else {
            XCTFail("This test required a hormone.")
            return
        }

        let notifications = MockNotifications()
        let alerts = MockAlertFactory()
        let testDate = DateFactory.createDate(byAddingHours: -2, to: Date())!
        let now = PDNow()
        let style = UIUserInterfaceStyle.dark
        let table = HormonesTable(UITableView(), sdk, style)
        let imageHistory = SiteImageHistory()
        let dependencies = MockDependencies()
        sdk.settings.setUseStaticExpirationTime(to: false)
        dependencies.sdk = sdk
        dependencies.notifications = notifications
        dependencies.alerts = alerts

        // Start off a hormone with a date.
        sdk.hormones.setDate(by: hormone.id, with: testDate)

        let hormonesViewModel = HormonesViewModel(
            siteImageHistory: imageHistory,
            style: style,
            table: table,
            dependencies: dependencies,
            now: now
        )

        hormonesViewModel.handleRowTapped(at: 0, dummyViewController) {}
        guard let hormoneAfterTest = sdk.hormones[hormone.id] else {
            XCTFail("Hormone somehow disappeared during test.")
            return
        }

        let changeAction = alerts.createHormoneActionsCallArgs[0].2
        changeAction()  // Simulates user selecting "Change" from the alert

        let actual = hormoneAfterTest.date
        PDAssertNotEquiv(testDate, actual)
    }

#endif
}
// swiftlint:enable function_body_length
