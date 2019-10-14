//
//  ShedulerTests.swift
//  TweenKit
//
//  Created by Steven Barnegren on 20/03/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import XCTest
@testable import TweenKit

class SchedulerTests: XCTestCase {
    
    var scheduler: ActionScheduler!
    
    override func setUp() {
        super.setUp()
        scheduler = ActionScheduler()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSchedulerReturnsCorrectNumberOfAnimations() {
        
        func addAnimation() {
            let action = InterpolationAction(from: 0.0, to: 1.0, duration: 1.0, easing: .linear, update: { _ in })
            let animation = Animation(action: action)
            scheduler.add(animation: animation)
        }
        
        XCTAssertEqual(scheduler.numRunningAnimations, 0)
        addAnimation()
        XCTAssertEqual(scheduler.numRunningAnimations, 1)
        addAnimation()
        XCTAssertEqual(scheduler.numRunningAnimations, 2)
        addAnimation()
        XCTAssertEqual(scheduler.numRunningAnimations, 3)
    }
    
    func testAnimationIsRemovedOnCompletion() {
        
        let duration = 0.1
        
        let action = InterpolationAction(from: 0.0, to: 1.0, duration: duration, easing: .linear) {_ in }
        let animation = Animation(action: action)
        scheduler.add(animation: animation)
        
        scheduler.progressTime(duration: duration + 0.1)
        XCTAssertEqual(scheduler.numRunningAnimations, 0)
    }
    
    func testAnimationFinishWhenRemoved() {
        
        var numCalls = 0
        
        let action1 = InterpolationAction(from: 0.0, to: 1.0, duration: 0.1, easing: .linear) {_ in }
        action1.onBecomeInactive = {
            numCalls += 1
        }
        let animation1 = Animation(action: action1)
        scheduler.add(animation: animation1)
        
        scheduler.remove(animation: animation1, forceFinish: false)
        
        XCTAssertEqual(numCalls, 0)
        
        numCalls = 0
        
        let action2 = InterpolationAction(from: 0.0, to: 1.0, duration: 0.1, easing: .linear) {_ in }
        action2.onBecomeInactive = {
            numCalls += 1
        }
        let animation2 = Animation(action: action2)
        scheduler.add(animation: animation2)

        scheduler.remove(animation: animation2, forceFinish: true)

        XCTAssertEqual(numCalls, 1)
    }
}
