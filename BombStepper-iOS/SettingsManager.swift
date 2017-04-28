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


// WISHLIST: Swipe down enable for each individual button
// WISHLIST: Button positioning settings, e.g. button size, slant, positions
// WISHLIST: Subscribe to settings messengers for specific value changes only
// WISHLIST: Holding on/off setting
final class SettingsManager {

    fileprivate enum SettingKey: String {
        case dasValue
        case dasFrames
        case softDropFrames
        case swipeDownThreshold
        case lrSwipeEnabled
        case ghostOpacity
        case hideGhost
        case gridsOpacity
        case button00, button01, button02, button03
        case button04, button05, button06, button07
        case button08, button09, button10, button11
        case swipeDrop00, swipeDrop01, swipeDrop02, swipeDrop03
        case swipeDrop04, swipeDrop05, swipeDrop06, swipeDrop07
        case swipeDrop08, swipeDrop09, swipeDrop10, swipeDrop11
    }

    // Initial values here match the actual default settings
    fileprivate(set) var dasValue: Int              = 9
    fileprivate(set) var dasFrames: Int             = 1
    fileprivate(set) var softDropFrames: Int        = 1
    fileprivate(set) var swipeDownThreshold: Double = 1000.0
    fileprivate(set) var lrSwipeEnabled: Bool       = true
    fileprivate(set) var ghostOpacity: Double       = 0.25
    fileprivate(set) var hideGhost: Bool            = false
    fileprivate(set) var gridsOpacity: Double       = 1.0
    fileprivate(set) var buttons: [Button]          = SettingsManager.defaultButtons
    fileprivate(set) var swipeDrop00: Bool          = true
    fileprivate(set) var swipeDrop01: Bool          = true
    fileprivate(set) var swipeDrop02: Bool          = true
    fileprivate(set) var swipeDrop03: Bool          = true
    fileprivate(set) var swipeDrop04: Bool          = true
    fileprivate(set) var swipeDrop05: Bool          = true
    fileprivate(set) var swipeDrop06: Bool          = true
    fileprivate(set) var swipeDrop07: Bool          = true
    fileprivate(set) var swipeDrop08: Bool          = true
    fileprivate(set) var swipeDrop09: Bool          = true
    fileprivate(set) var swipeDrop10: Bool          = true
    fileprivate(set) var swipeDrop11: Bool          = true

    static var defaultButtons: [Button] = [ .hardDrop, .hardDrop, .moveLeft, .moveRight,
                                            .softDrop, .softDrop, .hold, .hold,
                                            .rotateLeft, .rotateRight, .none, .none ]

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
                 SettingKey.swipeDownThreshold.rawValue : swipeDownThreshold,
                 SettingKey.lrSwipeEnabled.rawValue     : lrSwipeEnabled,
                 SettingKey.ghostOpacity.rawValue       : ghostOpacity,
                 SettingKey.hideGhost.rawValue          : hideGhost,
                 SettingKey.gridsOpacity.rawValue       : gridsOpacity,
                 SettingKey.button00.rawValue           : buttons[0].rawValue,
                 SettingKey.button01.rawValue           : buttons[1].rawValue,
                 SettingKey.button02.rawValue           : buttons[2].rawValue,
                 SettingKey.button03.rawValue           : buttons[3].rawValue,
                 SettingKey.button04.rawValue           : buttons[4].rawValue,
                 SettingKey.button05.rawValue           : buttons[5].rawValue,
                 SettingKey.button06.rawValue           : buttons[6].rawValue,
                 SettingKey.button07.rawValue           : buttons[7].rawValue,
                 SettingKey.button08.rawValue           : buttons[8].rawValue,
                 SettingKey.button09.rawValue           : buttons[9].rawValue,
                 SettingKey.button10.rawValue           : buttons[10].rawValue,
                 SettingKey.button11.rawValue           : buttons[11].rawValue,
                 SettingKey.swipeDrop00.rawValue        : swipeDrop00,
                 SettingKey.swipeDrop01.rawValue        : swipeDrop01,
                 SettingKey.swipeDrop02.rawValue        : swipeDrop02,
                 SettingKey.swipeDrop03.rawValue        : swipeDrop03,
                 SettingKey.swipeDrop04.rawValue        : swipeDrop04,
                 SettingKey.swipeDrop05.rawValue        : swipeDrop05,
                 SettingKey.swipeDrop06.rawValue        : swipeDrop06,
                 SettingKey.swipeDrop07.rawValue        : swipeDrop07,
                 SettingKey.swipeDrop08.rawValue        : swipeDrop08,
                 SettingKey.swipeDrop09.rawValue        : swipeDrop09,
                 SettingKey.swipeDrop10.rawValue        : swipeDrop10,
                 SettingKey.swipeDrop11.rawValue        : swipeDrop11]
    }

    func setValues(from dictionary: NSDictionary) {
        dasValue           = dictionary[SettingKey.dasValue.rawValue] as! Int
        dasFrames          = dictionary[SettingKey.dasFrames.rawValue] as! Int
        softDropFrames     = dictionary[SettingKey.softDropFrames.rawValue] as! Int
        swipeDownThreshold = dictionary[SettingKey.swipeDownThreshold.rawValue] as! Double
        lrSwipeEnabled     = dictionary[SettingKey.lrSwipeEnabled.rawValue] as! Bool
        ghostOpacity       = dictionary[SettingKey.ghostOpacity.rawValue] as! Double
        hideGhost          = dictionary[SettingKey.hideGhost.rawValue] as! Bool
        gridsOpacity       = dictionary[SettingKey.gridsOpacity.rawValue] as! Double
        buttons[00]        = Button(rawValue: dictionary[SettingKey.button00.rawValue] as! String)!
        buttons[01]        = Button(rawValue: dictionary[SettingKey.button01.rawValue] as! String)!
        buttons[02]        = Button(rawValue: dictionary[SettingKey.button02.rawValue] as! String)!
        buttons[03]        = Button(rawValue: dictionary[SettingKey.button03.rawValue] as! String)!
        buttons[04]        = Button(rawValue: dictionary[SettingKey.button04.rawValue] as! String)!
        buttons[05]        = Button(rawValue: dictionary[SettingKey.button05.rawValue] as! String)!
        buttons[06]        = Button(rawValue: dictionary[SettingKey.button06.rawValue] as! String)!
        buttons[07]        = Button(rawValue: dictionary[SettingKey.button07.rawValue] as! String)!
        buttons[08]        = Button(rawValue: dictionary[SettingKey.button08.rawValue] as! String)!
        buttons[09]        = Button(rawValue: dictionary[SettingKey.button09.rawValue] as! String)!
        buttons[10]        = Button(rawValue: dictionary[SettingKey.button10.rawValue] as! String)!
        buttons[11]        = Button(rawValue: dictionary[SettingKey.button11.rawValue] as! String)!
        swipeDrop00        = dictionary[SettingKey.swipeDrop00.rawValue] as! Bool
        swipeDrop01        = dictionary[SettingKey.swipeDrop01.rawValue] as! Bool
        swipeDrop02        = dictionary[SettingKey.swipeDrop02.rawValue] as! Bool
        swipeDrop03        = dictionary[SettingKey.swipeDrop03.rawValue] as! Bool
        swipeDrop04        = dictionary[SettingKey.swipeDrop04.rawValue] as! Bool
        swipeDrop05        = dictionary[SettingKey.swipeDrop05.rawValue] as! Bool
        swipeDrop06        = dictionary[SettingKey.swipeDrop06.rawValue] as! Bool
        swipeDrop07        = dictionary[SettingKey.swipeDrop07.rawValue] as! Bool
        swipeDrop08        = dictionary[SettingKey.swipeDrop08.rawValue] as! Bool
        swipeDrop09        = dictionary[SettingKey.swipeDrop09.rawValue] as! Bool
        swipeDrop10        = dictionary[SettingKey.swipeDrop10.rawValue] as! Bool
        swipeDrop11        = dictionary[SettingKey.swipeDrop11.rawValue] as! Bool
    }                                                
}


private class NotifyTargetWeakWrapper {
    weak var target: SettingsNotificationTarget?
    init(target: SettingsNotificationTarget) {
        self.target = target
    }
}




