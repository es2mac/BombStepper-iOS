//
//  SettingsManager.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/21/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


protocol SettingsNotificationTarget: class {
    // Called the first time added to the manager, and every time there's an update
    func settingsDidUpdate(_ settings: SettingsManager)
}


enum Button: String {
    case moveLeft
    case moveRight
    case hardDrop
    case softDrop
    case hold
    case rotateLeft
    case rotateRight
    case none
}


final class SettingsManager {

    fileprivate enum SettingKey: String {
        case dasValue
        case dasFrames
        case softDropFrames
        case swipeDropEnabled   
        case swipeDownThreshold
        case lrSwipeEnabled
        case ghostOpacity
        case button00, button01, button02, button03
        case button04, button05, button06, button07
        case button08, button09, button10, button11
    }

    // Initial values here match the actual default settings
    fileprivate(set) var dasValue: Int              = 9
    fileprivate(set) var dasFrames: Int             = 1
    fileprivate(set) var softDropFrames: Int        = 1
    fileprivate(set) var swipeDropEnabled: Bool     = true
    fileprivate(set) var swipeDownThreshold: Double = 1000.0
    fileprivate(set) var lrSwipeEnabled: Bool       = true
    fileprivate(set) var ghostOpacity: Double       = 0.25
    fileprivate(set) var button00: Button           = SettingsManager.defaultButtons[0]
    fileprivate(set) var button01: Button           = SettingsManager.defaultButtons[1]
    fileprivate(set) var button02: Button           = SettingsManager.defaultButtons[2]
    fileprivate(set) var button03: Button           = SettingsManager.defaultButtons[3]
    fileprivate(set) var button04: Button           = SettingsManager.defaultButtons[4]
    fileprivate(set) var button05: Button           = SettingsManager.defaultButtons[5]
    fileprivate(set) var button06: Button           = SettingsManager.defaultButtons[6]
    fileprivate(set) var button07: Button           = SettingsManager.defaultButtons[7]
    fileprivate(set) var button08: Button           = SettingsManager.defaultButtons[8]
    fileprivate(set) var button09: Button           = SettingsManager.defaultButtons[9]
    fileprivate(set) var button10: Button           = SettingsManager.defaultButtons[10]
    fileprivate(set) var button11: Button           = SettingsManager.defaultButtons[11]

    static var defaultButtons: [Button] = [ .hardDrop, .hardDrop, .moveLeft, .moveRight,
                                            .softDrop, .softDrop, .hold, .hold,
                                            .rotateLeft, .rotateRight, .none, .none ]

    var buttonsArray: [Button] {
        return [ button00, button01, button02, button03, button04, button05,
                 button06, button07, button08, button09, button10, button11 ]
    }

    fileprivate var notificationTargets = [NotifyTargetWeakWrapper]()

    fileprivate let queue = DispatchQueue(label: "net.mathemusician.BombStepper.SettingsManager", qos: .background)

    init() {
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] notification in
            guard let defaults = notification.object as? UserDefaults else { return }
            self?.fetchSettings(from: defaults)
        }
        defer {
            fetchSettings()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func addNotificationTargets(_ targets: [SettingsNotificationTarget]) {
        notificationTargets.append(contentsOf: targets.map(NotifyTargetWeakWrapper.init))
        targets.forEach { $0.settingsDidUpdate(self) }
    }
}


private extension SettingsManager {

    // Fetch settings, and if missing defaults, set to initial value
    func fetchSettings(from defaults: UserDefaults = .standard) {
        queue.async { self.fetchSettingsAsync(from: defaults) }
    }

    private func fetchSettingsAsync(from defaults: UserDefaults) {

        var defaultsWritten = false
        let oldDictionary = serializeValuesToDictionary()
        let newDictionary = NSMutableDictionary()

        for (key, oldValue) in oldDictionary {
            if let newValue = defaults.object(forKey: key) {
                newDictionary.setValue(newValue, forKey: key)
            }
            else {
                newDictionary.setValue(oldValue, forKey: key)
                defaults.set(oldValue, forKey: key)
                defaultsWritten = true
            }
        }

        if defaultsWritten { defaults.synchronize() }

        if !newDictionary.isEqual(to: oldDictionary) {
            setValues(from: newDictionary)
            notifyTargets()
        }
    }

    private func notifyTargets() {
        notificationTargets = notificationTargets.filter { targetWrapper in
            targetWrapper.target?.settingsDidUpdate(self)
            return targetWrapper.target != nil
        }
    }
}


private extension SettingsManager {
    func serializeValuesToDictionary() -> [String : Any] {
        return [ SettingKey.dasValue.rawValue           : dasValue,
                 SettingKey.dasFrames.rawValue          : dasFrames,
                 SettingKey.softDropFrames.rawValue     : softDropFrames,
                 SettingKey.swipeDropEnabled.rawValue   : swipeDropEnabled,
                 SettingKey.swipeDownThreshold.rawValue : swipeDownThreshold,
                 SettingKey.lrSwipeEnabled.rawValue     : lrSwipeEnabled,
                 SettingKey.ghostOpacity.rawValue       : ghostOpacity,
                 SettingKey.button00.rawValue : button00.rawValue,
                 SettingKey.button01.rawValue : button01.rawValue,
                 SettingKey.button02.rawValue : button02.rawValue,
                 SettingKey.button03.rawValue : button03.rawValue,
                 SettingKey.button04.rawValue : button04.rawValue,
                 SettingKey.button05.rawValue : button05.rawValue,
                 SettingKey.button06.rawValue : button06.rawValue,
                 SettingKey.button07.rawValue : button07.rawValue,
                 SettingKey.button08.rawValue : button08.rawValue,
                 SettingKey.button09.rawValue : button09.rawValue,
                 SettingKey.button10.rawValue : button10.rawValue,
                 SettingKey.button11.rawValue : button11.rawValue ]
    }

    func setValues(from dictionary: NSDictionary) {
        dasValue           = dictionary[SettingKey.dasValue.rawValue] as! Int
        dasFrames          = dictionary[SettingKey.dasFrames.rawValue] as! Int
        softDropFrames     = dictionary[SettingKey.softDropFrames.rawValue] as! Int
        swipeDropEnabled   = dictionary[SettingKey.swipeDropEnabled.rawValue] as! Bool
        swipeDownThreshold = dictionary[SettingKey.swipeDownThreshold.rawValue] as! Double
        lrSwipeEnabled     = dictionary[SettingKey.lrSwipeEnabled.rawValue] as! Bool
        ghostOpacity       = dictionary[SettingKey.ghostOpacity.rawValue] as! Double
        button00 = Button(rawValue: dictionary[SettingKey.button00.rawValue] as! String)!
        button01 = Button(rawValue: dictionary[SettingKey.button01.rawValue] as! String)!
        button02 = Button(rawValue: dictionary[SettingKey.button02.rawValue] as! String)!
        button03 = Button(rawValue: dictionary[SettingKey.button03.rawValue] as! String)!
        button04 = Button(rawValue: dictionary[SettingKey.button04.rawValue] as! String)!
        button05 = Button(rawValue: dictionary[SettingKey.button05.rawValue] as! String)!
        button06 = Button(rawValue: dictionary[SettingKey.button06.rawValue] as! String)!
        button07 = Button(rawValue: dictionary[SettingKey.button07.rawValue] as! String)!
        button08 = Button(rawValue: dictionary[SettingKey.button08.rawValue] as! String)!
        button09 = Button(rawValue: dictionary[SettingKey.button09.rawValue] as! String)!
        button10 = Button(rawValue: dictionary[SettingKey.button10.rawValue] as! String)!
        button11 = Button(rawValue: dictionary[SettingKey.button11.rawValue] as! String)!
    }
}


private class NotifyTargetWeakWrapper {
    weak var target: SettingsNotificationTarget?
    init(target: SettingsNotificationTarget) {
        self.target = target
    }
}




