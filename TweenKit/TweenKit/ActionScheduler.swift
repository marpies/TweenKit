//
//  Scheduler.swift
//  TweenKit
//
//  Created by Steve Barnegren on 18/03/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import Foundation
import QuartzCore

@objc public class ActionScheduler : NSObject {
    
    // MARK: - Public
    
    /**
    Run an action
    - Parameter action: The action to run
    - Returns: Animation instance. You may wish to keep this, so that you can remove the animation later using the remove(animation:) method
    */
    @discardableResult public func run(action: SchedulableAction) -> Animation {
        let animation = Animation(action: action)
        add(animation: animation)
        return animation
    }
    
    /**
     Adds an Animation to the scheduler. Usually you don't need to construct animations yourself, you can run the action directly.
     - Parameter animation: The animation to run
     */
    public func add(animation: Animation) {
        
        if self.isPaused {
            self.pausedAnimations.append(animation)
            return
        }
        
        animations.append(animation)
        animation.willStart()
        startLoop()
    }
    
    /**
     Removes a currently running animation
     - Parameter animation: The animation to remove
     - Parameter forceFinish: Determines whether the animation is finished when removed
     */
    public func remove(animation: Animation, forceFinish: Bool = true) {
        
        guard let index = animations.firstIndex(of: animation) else {
            
            // Check if the animation is paused
            if self.isPaused, let index = self.pausedAnimations.firstIndex(of: animation) {
                if forceFinish {
                    animation.didFinish()
                }
                self.pausedAnimations.remove(at: index)
            }
            return
        }
        
        if forceFinish {
            animation.didFinish()
        }
        animations.remove(at: index)
        
        if animations.isEmpty {
            stopLoop()
        }
    }
    
    /**
     Removes all animations
     */
    public func removeAll() {
        
        let allAnimations = animations
        allAnimations.forEach{
            self.remove(animation: $0)
        }
        
        self.pausedAnimations.removeAll()
    }
    
    /**
     Pauses all animations
     */
    public func pause() {
        guard !self.isPaused else {
            return
        }
        
        self.isPaused = true
        
        guard self.animations.count > 0 else {
            return
        }
        
        self.pausedAnimations.append(contentsOf: self.animations)
        self.animations.removeAll()
        
        self.stopLoop()
    }
    
    /**
     Resumes any previously paused animations
     */
    public func resume() {
        guard self.isPaused else {
            return
        }
        
        self.isPaused = false
        
        guard self.pausedAnimations.count > 0 else {
            return
        }
        
        for animation in self.pausedAnimations {
            if !animation.didStart {
                animation.willStart()
            }
        }
        
        self.animations.append(contentsOf: self.pausedAnimations)
        self.pausedAnimations.removeAll()
        
        self.startLoop()
    }
    
    /**
     The number of animations that are currently running
     */
    public var numRunningAnimations: Int {
        return self.animations.count
    }

    // MARK: - Properties
    
    private(set) var isPaused: Bool = false
    
    private var animations = [Animation]()
    private var animationsToRemove = [Animation]()
    private var pausedAnimations = [Animation]()

    private var displayLink: DisplayLink?
    private var lastTimeStamp: CFTimeInterval?
    
    // MARK: - Deinit
    
    deinit {
        stopLoop()
    }
    
    // MARK: - Manage Loop
    
    private func startLoop() {
        
        if displayLink != nil {
            return
        }
        
        lastTimeStamp = nil
        
        displayLink = DisplayLink(handler: {[unowned self] (displayLink) in
             self.displayLinkCallback(displaylink: displayLink)
        })
    }
    
    private func stopLoop() {
        
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func displayLinkCallback(displaylink: CADisplayLink) {
        
        // We need a previous time stamp to check against. Save if we don't already have one
        guard let last = lastTimeStamp else{
            lastTimeStamp = displaylink.timestamp
            return
        }
        
        // Update Animations
        let dt = displaylink.timestamp - last
        step(dt: dt)
        
        // Save the current time
        lastTimeStamp = displaylink.timestamp
    }
    
    func step(dt: Double) {
        
        for animation in animations {
            
            // Animations containing finite time actions
            if animation.hasDuration {
                
                var remove = false
                if animation.elapsedTime + dt > animation.duration {
                    remove = true
                }
                
                let newTime = (animation.elapsedTime + dt).constrained(max: animation.duration)
                animation.update(elapsedTime: newTime)
                
                if remove {
                    animationsToRemove.append(animation)
                }
            }
                
                // Animations containing infinite time actions
            else{
                
                let newTime = animation.elapsedTime + dt
                animation.update(elapsedTime: newTime)
            }
            
        }
        
        // Remove finished animations
        animationsToRemove.forEach{
            remove(animation: $0)
        }
        animationsToRemove.removeAll()

    }
}

@objc class DisplayLink : NSObject {
    
    var caDisplayLink: CADisplayLink? = nil
    let handler: (CADisplayLink) -> ()
    
    init(handler: @escaping (CADisplayLink) -> ()) {
        
        self.handler = handler
        
        super.init()
        
        caDisplayLink = CADisplayLink(target: self,
                                      selector: #selector(displayLinkCallback(displaylink:)))
        
        caDisplayLink?.add(to: .current,
                           forMode: .common)
        
    }
    
    @objc private func displayLinkCallback(displaylink: CADisplayLink) {
        self.handler(displaylink)
    }
    
    func invalidate() {
        caDisplayLink?.invalidate()
    }
}
