//
//  ButtonLayoutProfile.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/16/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


private let folderName = "ButtonLayouts"


enum SaveResult {
    case success
    case duplicateName
    case failed
}


class ButtonLayoutProfile {

    var name: String
    var buttons: [ButtonConfiguration] = []

    init(name: String) {
        self.name = name
        let config = ButtonConfiguration.standard
        buttons = [config, config]
    }

    class func listProfileNames() -> [String] {

        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(folderName)

        let files = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])


        return (files ?? []).map { $0.deletingPathExtension().lastPathComponent }
        
    }

    @discardableResult
    func save() -> SaveResult {

        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(folderName)

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





