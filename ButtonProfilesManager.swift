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

    func listProfileNames() -> [String] {
        return fileURLs.map { $0.deletingPathExtension().lastPathComponent }
    }

}

// TODO: Collection view data source


private extension ButtonProfilesManager {

    class var directoryURL: URL {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(DirectoryName.buttonLayouts)
    }

}




