//
//  ButtonProfilesManager.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/16/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


class ButtonProfilesManager {

    private lazy var fileURLs: [URL] = {
        let urls = try? FileManager.default.contentsOfDirectory(at: ButtonProfilesManager.directoryURL, includingPropertiesForKeys: nil, options: [])
        return urls ?? []
    }()

    var profileNames: [String] {
        return fileURLs.map { $0.deletingPathExtension().lastPathComponent }
    }

    // Default to max 20 profiles
    func nextGenericProfileName() -> String? {
        guard fileURLs.count < 20 else { return nil }
        let currentNames = Set(profileNames)
        for i in 1 ... 20 {
            let name = "Profile \(i)"
            if !currentNames.contains(name) {
                return name
            }
        }
        return nil
    }

    func isNameAvailable(_ name: String) -> Bool {
        return !name.isEmpty  && !profileNames.contains(name)
    }

}

// TODO: Collection view data source


private extension ButtonProfilesManager {

    class var directoryURL: URL {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(DirectoryName.buttonLayouts)
    }

}




