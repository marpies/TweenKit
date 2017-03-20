//
//  Animation.swift
//  TweenKit
//
//  Created by Steve Barnegren on 18/03/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import Foundation

public class Animation : Equatable {
    
    // MARK: - Public
    
    public init(action: SchedulableAction) {
        self.action = action
    }
    
    public func run(){
        Scheduler.shared.add(animation: self)
    }
    
    // MARK: - Properties

    var hasDuration: Bool {
        return action is FiniteTimeAction
    }
    
    var duration: Double {
        
        guard let ftAction = action as? FiniteTimeAction else {
            return 0
        }
        
        return ftAction.duration
    }
    
    var elapsedTime: CFTimeInterval = 0
    
    private let action: SchedulableAction!
    
    // MARK: - Methods
    
    func willStart() {
        //action.willBecomeActive()
        //action.willBegin()
    }
    
    func didFinish() {
        //action.didFinish()
        //action.didBecomeInactive()
    }
    
    func update(elapsedTime: CFTimeInterval) {
        
        self.elapsedTime = elapsedTime
        
        if let action = action as? FiniteTimeAction {
            action.update(t: elapsedTime / duration)
        }
        else if let action = action as? InfiniteTimeAction {
            action.update(elapsedTime: elapsedTime)
        }
    }
    
    
    
    
}

// MARK: - Equatable
public func ==(rhs: Animation, lhs: Animation) -> Bool {
    return rhs === lhs
}
