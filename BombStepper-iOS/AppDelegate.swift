//
//  AppDelegate.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/17/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


//        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { notification in
//            print(notification)
//        }


        // TODO: If first launch, register all setting defaults
        // (it does not automatically set from the settings bundle)

        /*
        UserDefaults.standard.set("none", forKey: "button04")
        UserDefaults.standard.synchronize()

        print(UserDefaults.standard.string(forKey: "button00") as Any)
        print(UserDefaults.standard.string(forKey: "button01") as Any)
        print(UserDefaults.standard.string(forKey: "button02") as Any)
        print(UserDefaults.standard.string(forKey: "button03") as Any)
        print(UserDefaults.standard.string(forKey: "button04") as Any)
        print(UserDefaults.standard.string(forKey: "button05") as Any)
        print(UserDefaults.standard.string(forKey: "button06") as Any)
        print(UserDefaults.standard.string(forKey: "button07") as Any)
        print(UserDefaults.standard.string(forKey: "button08") as Any)
        print(UserDefaults.standard.string(forKey: "button09") as Any)
        print(UserDefaults.standard.string(forKey: "button10") as Any)
        print(UserDefaults.standard.string(forKey: "button11") as Any)
        print(UserDefaults.standard.string(forKey: "button12") as Any)
         */
        
        return true
    }


}

