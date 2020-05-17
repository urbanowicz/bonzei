//
//  BonzeiTests.swift
//  BonzeiTests
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import XCTest
@testable import Bonzei

class BonzeiTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAlarm1() {
        let now = Date()
        
        let alarm = Alarm(
            id: "A1",
            date: now,
            repeatOn: [],
            melodyName: "melody",
            snoozeEnabled: true,
            isActive: true,
            lastTriggerDate: nil,
            lastUpdateDate: nil)
        
        XCTAssertEqual(alarm.hour, now.hour)
        XCTAssertEqual(alarm.minute, now.minute)
    }

    func testDateExtension1() {
        let now = Date()
        
        let triggerDate = now
            .new(bySetting: .hour, to: 10)
            .new(bySetting: .minute, to: 15)
            .new(bySetting: .second, to: 0)
    
        
        XCTAssertEqual(triggerDate.hour, 10)
        XCTAssertEqual(triggerDate.minute, 15)
        XCTAssertEqual(triggerDate.second, 0)
    }
}
