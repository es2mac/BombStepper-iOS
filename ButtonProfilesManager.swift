//
//  ButtonProfilesManager.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/16/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


private let selectedButtonProfileKey = "kSelectedButtonProfileKey"


enum SaveResult {
    case success
    case duplicateName
    case failed
}


/// Mainly deal with writing/reading button layout profiles to/from files
class ButtonProfilesManager: NSObject {

    private(set) var profileNames: [String] = []
    
    var selectedProfileName: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: selectedButtonProfileKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: selectedButtonProfileKey)
        }
    }

    override init() {
        super.init()
        reload()
    }

    private func reload() {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: ButtonProfilesManager.directoryURL, includingPropertiesForKeys: [.contentModificationDateKey], options: []) else { return }

        let plistURLs = urls.filter { $0.pathExtension == "plist" }
        let sortedURLs: [URL]

        do {
            let modificationDates = try plistURLs.flatMap { try $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate }
            if modificationDates.count == plistURLs.count {
                sortedURLs = zip(plistURLs, modificationDates).sorted(by: { $0.1 > $1.1 }).map { $0.0 }
            }
            else {
                sortedURLs = plistURLs
            }
        }
        catch {
            sortedURLs = plistURLs
        }

        profileNames = sortedURLs.map { $0.deletingPathExtension().lastPathComponent }
    }

    // Default to max 20 profiles,returns nil if cannot create any more
    func nextProfileName(from name: String? = nil) -> String? {
        guard profileNames.count < 20 else { return nil }

        let base: String

        if let originalName = name, !originalName.isEmpty {

            let components = originalName.components(separatedBy: " ")

            if Int(components.last!) == nil {
                base = originalName
            }
            else {
                base = components.dropLast().joined(separator: " ")
            }

        } else {
            base = "Profile"
        }

        if isNameAvailable(base) { return base }

        let currentNames = Set(profileNames)

        for i in 2 ... 20 {
            let name = "\(base) \(i)"
            if !currentNames.contains(name) {
                return name
            }
        }

        assertionFailure()
        return nil
    }

    func isNameAvailable(_ name: String) -> Bool {
        return !name.isEmpty && !profileNames.contains(name)
    }

    @discardableResult
    func save(_ profile: ButtonLayoutProfile) -> SaveResult {

        let url = ButtonProfilesManager.directoryURL

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
            let dictionary = profile.encodeAsDictionary()
            let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
            let fileURL = url.appendingPathComponent(profile.name).appendingPathExtension("plist")
            try data.write(to: fileURL)
        }
        catch {
            return .failed
        }

        reload()

        return .success
    }

    func loadProfile(at index: Int) -> ButtonLayoutProfile? {

        let url = ButtonProfilesManager.directoryURL.appendingPathComponent(profileNames[index]).appendingPathExtension("plist")
        var format = PropertyListSerialization.PropertyListFormat.xml

        if let data = FileManager.default.contents(atPath: url.path),
            let serialized = try? PropertyListSerialization.propertyList(from: data, options: [], format: &format),
            let dictionary = serialized as? [String : Any],
            let profile = ButtonLayoutProfile(dictionary: dictionary) {
            return profile
        }

        return nil
    }
    
    func loadImage(named name: String) -> UIImage? {
        let url = ButtonProfilesManager.directoryURL.appendingPathComponent(name).appendingPathExtension("png")
        return UIImage(contentsOfFile: url.path)
    }
    
    func deleteProfile(at index: Int) -> Bool {

        let url = ButtonProfilesManager.directoryURL.appendingPathComponent(profileNames[index]).appendingPathExtension("plist")

        do {
            try FileManager.default.removeItem(at: url)
        }
        catch {
            assertionFailure()
            return false
        }

        reload()

        return true
    }

    func saveImage(image: UIImage, name: String) {
        
        let data = UIImagePNGRepresentation(image)!
        let url = ButtonProfilesManager.directoryURL.appendingPathComponent(name).appendingPathExtension("png")
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
    }

}


// TODO: Read or create thumbnail and save with the same name


private extension ButtonProfilesManager {

    class var directoryURL: URL {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(DirectoryName.buttonLayouts)
    }

}






