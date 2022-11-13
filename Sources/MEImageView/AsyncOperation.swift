//
//  AsyncOperation.swift
//  MEImageView
//
//  Created by Pablo Ezequiel Romero Giovannoni on 24/04/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

open class AsyncOperation: Operation {

    private enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var state: State = .ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    public override var isAsynchronous: Bool {
        return true
    }
    
    public override var isReady: Bool {
        return state == .ready
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    public override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        if !isExecuting {
            state = .executing
        }
        main()
    }
    
    public func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    open override func cancel() {
        super.cancel()
        finish()
    }
    
}
