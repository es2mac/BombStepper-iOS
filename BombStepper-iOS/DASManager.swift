//
//  DASManager.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/20/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


final class DASManager {

    enum Direction {
        case left, right
    }

    private enum Status {
        case none
        case pending(Direction, fire: MachAbsTime)
        case imminent(Direction)   // Only when mach_waiting, within 1 frame time
        case active(Direction)

        var direction: Direction? {
            switch self {
            case .pending(let d, _), .imminent(let d), .active(let d):
                return d
            default:
                return nil
            }
        }
    }


    private var dasStatus: Status
    private let dasDelay: MachAbsTime
    // High priority queue with possible mach_wait for precision DAS firing
    private let dasPendingQueue: DispatchQueue

    private let performDAS: (Direction) -> Void


    /// Note: performDAS is usually called off the main thread
    init(das: Int, performDAS: @escaping (Direction) -> Void) {
        dasDelay = msToAbs(Double(das) * 1000 / 60)
        dasStatus = Status.none
        dasPendingQueue = DispatchQueue.global(qos: .userInteractive)
        self.performDAS = performDAS
    }


    func inputBegan(_ direction: Direction) {
        let dasFireTime = mach_absolute_time() + dasDelay
        switch direction {
        case .left:
            dasStatus = Status.pending(Direction.left, fire: dasFireTime)
        case .right:
            dasStatus = Status.pending(Direction.right, fire: dasFireTime)
        }
    }

    func inputEnded(_ direction: Direction) {
        if direction == dasStatus.direction {
            dasStatus = .none
        }
    }

    func update() {
        switch dasStatus {
        case .active(let direction):
            performDAS(direction)
        case .pending(let direction, let t):
            activateDASIfNeeded(direction: direction, fireTime: t)
        default:
            break
        }
    }

    private func activateDASIfNeeded(direction: Direction, fireTime: MachAbsTime) {
        let now = mach_absolute_time()

        guard fireTime < now + singleFrameTime else { return }

        if fireTime < now {
            dasStatus = .active(direction)
            performDAS(direction)
        }
        else {
            dasStatus = .imminent(direction)
            dasPendingQueue.async {
                mach_wait_until(fireTime)
                if case .imminent(let d) = self.dasStatus, d == direction {
                    self.dasStatus = .active(direction)
                    self.performDAS(direction)
                }
            }
        }
    }

}


// Convenience functions dealing with high-precision timing
private typealias MachAbsTime = UInt64

private func absToMs(_ abs: MachAbsTime) -> Double {
    var info : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    mach_timebase_info(&info)
    let nanos = abs * UInt64(info.numer) / UInt64(info.denom)
    return Double(nanos) / Double(NSEC_PER_MSEC)
}


private func msToAbs(_ ms: Double) -> MachAbsTime {
    var info : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    mach_timebase_info(&info)
    let nanos = UInt64(ms * Double(NSEC_PER_MSEC))
    return nanos * UInt64(info.denom) / UInt64(info.numer)
}

// 60Hz single frame absolute time
private let singleFrameTime: MachAbsTime = msToAbs(1 * 1000 / 60)


/*
 // Debug timing
 let now = mach_absolute_time()

 guard now >= fireTime else {
 let timeEarly = absToMs(fireTime - now)
 print("BeginDAS fired EARLY by", timeEarly, "ms")
 return
 }

 let latency = absToMs(now - fireTime)

 print("Latency:", latency)
 */

