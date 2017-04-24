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
    func settingsDidUpdate(_ settings: SettingsManager.Settings)
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

    struct Settings {

        private enum SettingKey: String {
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

        fileprivate static let initialValuesDictionary: [String : Any] =
            [ SettingKey.dasValue.rawValue : 9,
              SettingKey.dasFrames.rawValue : 1,
              SettingKey.softDropFrames.rawValue : 1,
              SettingKey.swipeDropEnabled.rawValue : true,
              SettingKey.swipeDownThreshold.rawValue : 1000.0,
              SettingKey.lrSwipeEnabled.rawValue : true,
              SettingKey.ghostOpacity.rawValue : 0.25,
              SettingKey.button00.rawValue : Button.hardDrop.rawValue,
              SettingKey.button01.rawValue : Button.hardDrop.rawValue,
              SettingKey.button02.rawValue : Button.moveLeft.rawValue,
              SettingKey.button03.rawValue : Button.moveRight.rawValue,
              SettingKey.button04.rawValue : Button.softDrop.rawValue,
              SettingKey.button05.rawValue : Button.softDrop.rawValue,
              SettingKey.button06.rawValue : Button.hold.rawValue,
              SettingKey.button07.rawValue : Button.hold.rawValue,
              SettingKey.button08.rawValue : Button.rotateLeft.rawValue,
              SettingKey.button09.rawValue : Button.rotateRight.rawValue,
              SettingKey.button10.rawValue : Button.none.rawValue,
              SettingKey.button11.rawValue : Button.none.rawValue ]
        

        let dasValue: Int
        let dasFrames: Int
        let softDropFrames: Int
        let swipeDropEnabled: Bool
        let swipeDownThreshold: Double
        let lrSwipeEnabled: Bool
        let ghostOpacity: Double
        let button00: Button
        let button01: Button
        let button02: Button
        let button03: Button
        let button04: Button
        let button05: Button
        let button06: Button
        let button07: Button
        let button08: Button
        let button09: Button
        let button10: Button
        let button11: Button


        static let initial = Settings(dictionary: initialValuesDictionary)


        init(dictionary: [String : Any]) {
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


    fileprivate var currentSettings = Settings.initial

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
        targets.forEach { $0.settingsDidUpdate(currentSettings) }
    }
}


private extension SettingsManager {

    // Fetch settings, and if missing defaults, set to initial value
    func fetchSettings(from defaults: UserDefaults = .standard) {
        queue.async { self.fetchSettingsAsync(from: defaults) }
    }

    private func fetchSettingsAsync(from defaults: UserDefaults) {

        var defaultsWritten = false
        var dictionary = [String : Any]()
        
        for (key, initialValue) in Settings.initialValuesDictionary {
            if let value = defaults.object(forKey: key) {
                dictionary[key] = value
            }
            else {
                dictionary[key] = initialValue
                defaults.set(initialValue, forKey: key)
                defaultsWritten = true
            }
        }

        if defaultsWritten { defaults.synchronize() }

        let newSettings = Settings(dictionary: dictionary)
        if newSettings != currentSettings {
            currentSettings = newSettings
            notifyTargets()
        }
    }

    private func notifyTargets() {
        notificationTargets = notificationTargets.filter { targetWrapper in
            targetWrapper.target?.settingsDidUpdate(currentSettings)
            return targetWrapper.target != nil
        }
    }
}


private class NotifyTargetWeakWrapper {
    weak var target: SettingsNotificationTarget?
    init(target: SettingsNotificationTarget) {
        self.target = target
    }
}


extension SettingsManager.Settings: Equatable { }

func ==(lhs: SettingsManager.Settings, rhs: SettingsManager.Settings) -> Bool {
    return lhs.dasValue        == rhs.dasValue &&
        lhs.dasFrames          == rhs.dasFrames &&
        lhs.softDropFrames     == rhs.softDropFrames &&
        lhs.swipeDropEnabled   == rhs.swipeDropEnabled &&
        lhs.swipeDownThreshold == rhs.swipeDownThreshold &&
        lhs.lrSwipeEnabled     == rhs.lrSwipeEnabled &&
        lhs.ghostOpacity       == rhs.ghostOpacity &&
        lhs.button00           == rhs.button00 &&
        lhs.button01           == rhs.button01 &&
        lhs.button02           == rhs.button02 &&
        lhs.button03           == rhs.button03 &&
        lhs.button04           == rhs.button04 &&
        lhs.button05           == rhs.button05 &&
        lhs.button06           == rhs.button06 &&
        lhs.button07           == rhs.button07 &&
        lhs.button08           == rhs.button08 &&
        lhs.button09           == rhs.button09 &&
        lhs.button10           == rhs.button10 &&
        lhs.button11           == rhs.button11
}




