//
//  MachTiming.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/29/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


typealias MachAbsTime = UInt64

func absToMs(_ abs: MachAbsTime) -> Double {
    var info : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    mach_timebase_info(&info)
    let nanos = abs * UInt64(info.numer) / UInt64(info.denom)
    return Double(nanos) / Double(NSEC_PER_MSEC)
}


func msToAbs(_ ms: Double) -> MachAbsTime {
    var info : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    mach_timebase_info(&info)
    let nanos = UInt64(ms * Double(NSEC_PER_MSEC))
    return nanos * UInt64(info.denom) / UInt64(info.numer)
}


// 60Hz single frame absolute time
let singleFrameTime: MachAbsTime = msToAbs(1 * 1000 / 60)

