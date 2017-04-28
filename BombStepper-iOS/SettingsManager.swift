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
        case button00, button01, button02, button03, button04, button05
        case button06, button07, button08, button09, button10, button11
        case swipeDrop00, swipeDrop01, swipeDrop02, swipeDrop03, swipeDrop04, swipeDrop05
        case swipeDrop06, swipeDrop07, swipeDrop08, swipeDrop09, swipeDrop10, swipeDrop11

        static let buttonKeys: [String] = [SettingKey.button00, .button01, .button02, .button03,
                                           .button04, .button05, .button06, .button07,
                                           .button08, .button09, .button10, .button11].map { $0.rawValue }

        static let swipeDropKeys: [String] = [SettingKey.swipeDrop00, .swipeDrop01, .swipeDrop02, .swipeDrop03,
                                              .swipeDrop04, .swipeDrop05, .swipeDrop06, .swipeDrop07,
                                              .swipeDrop08, .swipeDrop09, .swipeDrop10, .swipeDrop11].map { $0.rawValue }
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
    fileprivate(set) var swipeDrops: [Bool]         = [Bool](repeating: true, count: 12)

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
        var dictionary: [String : Any] = [ SettingKey.dasValue.rawValue           : dasValue,
                                           SettingKey.dasFrames.rawValue          : dasFrames,
                                           SettingKey.softDropFrames.rawValue     : softDropFrames,
                                           SettingKey.swipeDownThreshold.rawValue : swipeDownThreshold,
                                           SettingKey.lrSwipeEnabled.rawValue     : lrSwipeEnabled,
                                           SettingKey.ghostOpacity.rawValue       : ghostOpacity,
                                           SettingKey.hideGhost.rawValue          : hideGhost,
                                           SettingKey.gridsOpacity.rawValue       : gridsOpacity ]

        for (key, button) in zip(SettingKey.buttonKeys, buttons) { dictionary[key] = button.rawValue }
        for (key, swipeDrop) in zip(SettingKey.swipeDropKeys, swipeDrops) { dictionary[key] = swipeDrop}

        return dictionary
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
        buttons            = SettingKey.buttonKeys.map { Button(rawValue: dictionary[$0] as! String)! }
        swipeDrops         = SettingKey.swipeDropKeys.map { dictionary[$0] as! Bool }
    }
}


private class NotifyTargetWeakWrapper {
    weak var target: SettingsNotificationTarget?
    init(target: SettingsNotificationTarget) {
        self.target = target
    }
}




