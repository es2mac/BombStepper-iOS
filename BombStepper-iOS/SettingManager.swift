//
//  SettingManager.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/21/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation



final class SettingManager {

    struct Settings {

        enum SettingKey {
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

        enum ButtonValue {
            static let moveLeft    = "moveLeft"
            static let moveRight   = "moveRight"
            static let hardDrop    = "hardDrop"
            static let softDrop    = "softDrop"
            static let hold        = "hold"
            static let rotateLeft  = "rotateLeft"
            static let rotateRight = "rotateRight"
            static let none        = "none"
        }

        fileprivate static let initialValuesDictionary: [String : Any] =
            [ SettingKey.dasValue : 9,
              SettingKey.swipeDropEnabled : true,
              SettingKey.swipeDownThreshold : 1250.0,
              SettingKey.button00 : ButtonValue.hardDrop,
              SettingKey.button01 : ButtonValue.hardDrop,
              SettingKey.button02 : ButtonValue.moveLeft,
              SettingKey.button03 : ButtonValue.moveRight,
              SettingKey.button04 : ButtonValue.softDrop,
              SettingKey.button05 : ButtonValue.softDrop,
              SettingKey.button06 : ButtonValue.hold,
              SettingKey.button07 : ButtonValue.hold,
              SettingKey.button08 : ButtonValue.rotateLeft,
              SettingKey.button09 : ButtonValue.rotateRight,
              SettingKey.button10 : ButtonValue.none,
              SettingKey.button11 : ButtonValue.none ]
        

        let dasValue: Int
        let swipeDropEnabled: Bool
        let swipeDownThreshold: Double
        let button00: String
        let button01: String
        let button02: String
        let button03: String
        let button04: String
        let button05: String
        let button06: String
        let button07: String
        let button08: String
        let button09: String
        let button10: String
        let button11: String


        init(dictionary: [String : Any]) {
            dasValue = dictionary[SettingKey.dasValue] as! Int
            swipeDropEnabled = dictionary[SettingKey.swipeDropEnabled] as! Bool
            swipeDownThreshold = dictionary[SettingKey.swipeDownThreshold] as! Double
            button00 = dictionary[SettingKey.button00] as! String
            button01 = dictionary[SettingKey.button01] as! String
            button02 = dictionary[SettingKey.button02] as! String
            button03 = dictionary[SettingKey.button03] as! String
            button04 = dictionary[SettingKey.button04] as! String
            button05 = dictionary[SettingKey.button05] as! String
            button06 = dictionary[SettingKey.button06] as! String
            button07 = dictionary[SettingKey.button07] as! String
            button08 = dictionary[SettingKey.button08] as! String
            button09 = dictionary[SettingKey.button09] as! String
            button10 = dictionary[SettingKey.button10] as! String
            button11 = dictionary[SettingKey.button11] as! String
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

    var temporarilyIgnoreChangeNotifications = false
    private func settingsDidChange(notification: Notification) {
        guard let defaults = notification.object as? UserDefaults else { return }

        if temporarilyIgnoreChangeNotifications == false {
            fetchSettings(from: defaults)
            print(defaults)
        }
    }

    // Fetch settings, and if missing defaults, set default settings
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
                
                print("Setting", initialValue, "for", key)
            }
        }
        
        if defaultsWritten { defaults.synchronize() }
        
        updateSettingsAction?(Settings(dictionary: dictionary))
    }

}





