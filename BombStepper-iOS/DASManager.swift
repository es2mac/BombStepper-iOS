//
//  DASManager.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/20/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/// The DAS Manager relies on being updated each frame for timing
final class DASManager {

    fileprivate enum Status {
        case none
        case pending(XDirection, fire: MachAbsTime)
        case imminent(XDirection)   // Only when mach_waiting, within 1 frame time
        case active(XDirection)

        var direction: XDirection? {
            switch self {
            case .pending(let d, _), .imminent(let d), .active(let d):
                return d
            default:
                return nil
            }
        }
    }


    var activateDAS: ((_ active: Bool, _ direction: XDirection) -> Void)?

    fileprivate var dasStatus: Status
    fileprivate var dasDelay: MachAbsTime
    // High priority queue for mach_wait for precision DAS firing
    private let dasPendingQueue = DispatchQueue(label: "net.mathemusician.BombStepper.DASManager", qos: .userInteractive)
    

    /// Note: activateDAS is usually called off the main thread
    init(activateDAS: ((Bool, XDirection) -> Void)? = nil) {
        dasDelay = msToAbs(8 * 1000 / 60)   // Updates on settings manager callback
        dasStatus = Status.none
        self.activateDAS = activateDAS
    }

    func inputBegan(_ direction: XDirection) {
        let dasFireTime = mach_absolute_time() + dasDelay
        dasStatus = Status.pending(direction, fire: dasFireTime)
    }

    func inputEnded(_ direction: XDirection) {
        if direction == dasStatus.direction {
            dasStatus = .none
            activateDAS?(false, direction)
        }
    }

    func reset() {
        dasStatus = .none
    }

    fileprivate func activateDASIfNeeded(direction: XDirection, fireTime: MachAbsTime) {
        let now = mach_absolute_time()

        guard fireTime < now + singleFrameTime else { return }

        if fireTime < now {
            dasStatus = .active(direction)
            activateDAS?(true, direction)
        }
        else {
            dasStatus = .imminent(direction)
            dasPendingQueue.async {
                mach_wait_until(fireTime)
                if case .imminent(let d) = self.dasStatus, d == direction {
                    self.dasStatus = .active(direction)
                    self.activateDAS?(true, direction)
                }
            }
        }
    }
}


extension DASManager: GameSceneUpdatable {
    func update(_ currentTime: TimeInterval) {
        if case .pending(let direction, let t) = dasStatus {
            activateDASIfNeeded(direction: direction, fireTime: t)
        }
    }
}


extension DASManager: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        dasDelay = msToAbs(Double(settings.dasValue) * 1000 / 60)
    }
}



