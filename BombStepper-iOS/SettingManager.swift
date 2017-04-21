//
//  SettingManager.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/21/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


enum Button: String {
    case moveLeft    = "moveLeft"
    case moveRight   = "moveRight"
    case hardDrop    = "hardDrop"
    case softDrop    = "softDrop"
    case hold        = "hold"
    case rotateLeft  = "rotateLeft"
    case rotateRight = "rotateRight"
    case none        = "none"
}


final class SettingManager {

    struct Settings {

        private enum SettingKey {
            static let dasValue           = "dasValue"
            static let swipeDropEnabled   = "swipeDropEnabled"
            static let swipeDownThreshold = "swipeDownThreshold"
            static let button00           = "button00"
            static let button01           = "button01"
            static let button02           = "button02"
            static let button03           = "button03"
            static let button04           = "button04"
            static let button05           = "button05"
            static let button06           = "button06"
            static let button07           = "button07"
            static let button08           = "button08"
            static let button09           = "button09"
            static let button10           = "button10"
            static let button11           = "button11"
        }

        fileprivate static let initialValuesDictionary: [String : Any] =
            [ SettingKey.dasValue : 9,
              SettingKey.swipeDropEnabled : true,
              SettingKey.swipeDownThreshold : 1000.0,
              SettingKey.button00 : Button.hardDrop.rawValue,
              SettingKey.button01 : Button.hardDrop.rawValue,
              SettingKey.button02 : Button.moveLeft.rawValue,
              SettingKey.button03 : Button.moveRight.rawValue,
              SettingKey.button04 : Button.softDrop.rawValue,
              SettingKey.button05 : Button.softDrop.rawValue,
              SettingKey.button06 : Button.hold.rawValue,
              SettingKey.button07 : Button.hold.rawValue,
              SettingKey.button08 : Button.rotateLeft.rawValue,
              SettingKey.button09 : Button.rotateRight.rawValue,
              SettingKey.button10 : Button.none.rawValue,
              SettingKey.button11 : Button.none.rawValue ]
        

        let dasValue: Int
        let swipeDropEnabled: Bool
        let swipeDownThreshold: Double
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


        static var initial = Settings(dictionary: initialValuesDictionary)


        init(dictionary: [String : Any]) {
            dasValue = dictionary[SettingKey.dasValue] as! Int
            swipeDropEnabled = dictionary[SettingKey.swipeDropEnabled] as! Bool
            swipeDownThreshold = dictionary[SettingKey.swipeDownThreshold] as! Double
            button00 = Button(rawValue: dictionary[SettingKey.button00] as! String)!
            button01 = Button(rawValue: dictionary[SettingKey.button01] as! String)!
            button02 = Button(rawValue: dictionary[SettingKey.button02] as! String)!
            button03 = Button(rawValue: dictionary[SettingKey.button03] as! String)!
            button04 = Button(rawValue: dictionary[SettingKey.button04] as! String)!
            button05 = Button(rawValue: dictionary[SettingKey.button05] as! String)!
            button06 = Button(rawValue: dictionary[SettingKey.button06] as! String)!
            button07 = Button(rawValue: dictionary[SettingKey.button07] as! String)!
            button08 = Button(rawValue: dictionary[SettingKey.button08] as! String)!
            button09 = Button(rawValue: dictionary[SettingKey.button09] as! String)!
            button10 = Button(rawValue: dictionary[SettingKey.button10] as! String)!
            button11 = Button(rawValue: dictionary[SettingKey.button11] as! String)!
        }
    }

    // Provide current settings, called on first set and whenever settings update
    // Called on background queue because I don't know how heavy the defaults operations are
    var updateSettingsAction: ((Settings) -> Void)? {
        didSet {
            fetchSettings()
        }
    }

    init() {
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] notification in
            self?.settingsDidChange(notification: notification)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private var temporarilyIgnoreChangeNotifications = false

    private func settingsDidChange(notification: Notification) {
        guard let defaults = notification.object as? UserDefaults else { return }

        if temporarilyIgnoreChangeNotifications == false {
            fetchSettings(from: defaults)
        }
    }

    // Fetch settings, and if missing defaults, set to initial value
    private func fetchSettings(from defaults: UserDefaults = .standard) {
        DispatchQueue.global(qos: .background).async {
            self.temporarilyIgnoreChangeNotifications = true
            self.fetchSettingsAsynchronously(from: defaults)
            self.temporarilyIgnoreChangeNotifications = false
        }
    }

    private func fetchSettingsAsynchronously(from defaults: UserDefaults) {

        guard updateSettingsAction != nil else { return }

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
        
        updateSettingsAction?(Settings(dictionary: dictionary))
    }

}





