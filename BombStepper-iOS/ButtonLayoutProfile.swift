//
//  ButtonLayoutProfile.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/16/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


private enum Keys {
    static let name: String = "name"
    static let modificationDate: String = "modificationDate"
    static let buttons: String = "buttons"
}


struct ButtonLayoutProfile {

    var name: String
    var modificationDate: Date = Date()
    var buttons: [ButtonConfiguration] = []

    init(name: String) {
        self.name = name
        let config = ButtonConfiguration.standard
        buttons = [config, config]
    }

    @discardableResult
    func save() -> SaveResult {

        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(DirectoryName.buttonLayouts)

        var isDirectory: ObjCBool = true
        if !(FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue == true) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                return .failed
            }
        }

        do {
            let buttonDictionaries = buttons.map { $0.encodeAsDictionary() }
            let data = try PropertyListSerialization.data(fromPropertyList: buttonDictionaries, format: .xml, options: 0)
            let fileURL = url.appendingPathComponent(name).appendingPathExtension("plist")
            try data.write(to: fileURL)
        }
        catch {
            return .failed
        }
        
        return .success
    }
}


extension ButtonLayoutProfile {

    func encodeAsDictionary() -> [String : Any] {
        return [ Keys.name             : name,
                 Keys.modificationDate : modificationDate,
                 Keys.buttons          : buttons.map { $0.encodeAsDictionary() } ]
    }

    init?(dictionary: [String : Any]) {

        guard let name = dictionary[Keys.name] as? String,
            let modificationDate = dictionary[Keys.modificationDate] as? Date,
            let buttons = dictionary[Keys.buttons] as? [[String : Any]] else {
                return nil
        }

        self.name = name
        self.modificationDate = modificationDate
        self.buttons = buttons.flatMap { ButtonConfiguration(dictionary: $0) }
    }

}


extension ButtonLayoutProfile: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Name:\(name)\nDate: \(modificationDate)\nButtons:\(buttons)"
    }
}





