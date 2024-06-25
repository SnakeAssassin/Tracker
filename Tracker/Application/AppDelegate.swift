//
//  AppDelegate.swift
//  Tracker
//
//  Created by Joe Kramer on 12.03.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
        DaysValueTransformer.register()
        return true
    }

//    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", 
                                    sessionRole: connectingSceneSession.role)
    }

    // MARK: - CoreData контейнер

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

