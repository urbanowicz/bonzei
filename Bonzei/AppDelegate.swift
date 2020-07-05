//
//  AppDelegate.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import CoreData
import os.log
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private var lifeCycleLog = OSLog(subsystem: "App", category: "LifeCycle")
    
    private let dispatchGroup = DispatchGroup()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Get notified when iOS delivers notifications you have scheduled
        UNUserNotificationCenter.current().delegate = self
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        syncArticles()
        dispatchGroup.notify(queue: .main) {
            print("B")
        }
        return true
    }
    
    func syncArticles() {
        self.dispatchGroup.enter()
        
        let articlesProvider = FirebaseArticlesProvider.sharedInstance
        let localArticlesDb =  ArticlePersistenceService.sharedInstance
        let appVersionService = AppVersionService.sharedInstance
        
        if appVersionService.getAppVersionInstalledOnDevice() != APP_VERSION {
            print("DELETE")
            localArticlesDb.deleteAll()
            appVersionService.updateAppVersion(to: APP_VERSION)
        }
        
        print("A0")
        articlesProvider.syncWithBackend() {
            
            guard var articles = localArticlesDb.readAll() else { return }
        
            for i in 0..<articles.count {
               
                if articles[i].coverImage == nil {
                    self.dispatchGroup.enter()
                    articlesProvider.getUIImage(forURL: articles[i].coverImageURL) {
                        coverImage in
                        
                        articles[i].coverImage = coverImage
                        localArticlesDb.update(article: articles[i])
                        self.dispatchGroup.leave()
                        print("A1")
                    }
                }
                
                if articles[i].largeCoverImage == nil {
                    self.dispatchGroup.enter()
                    articlesProvider.getUIImage(forURL: articles[i].largeCoverImageURL) {
                        largeCoverImage in
                        
                        articles[i].largeCoverImage = largeCoverImage
                        localArticlesDb.update(article: articles[i])
                        self.dispatchGroup.leave()
                        print("A2")
                    }
                }
            }
            self.dispatchGroup.leave()
            print("A3")
        }

    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
    
    }
    
    @objc func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        os_log("Application will terminate", log: lifeCycleLog, type: .info)
        
        // 1. If a user has snoozed an alarm and then has closed the application then we want to cancel all snoozed alarms.
        // An alternative would be to clean expired snoozes that haven't triggered because app was closed
        // in 'application did finish launching with options'.
        // Canceling all snoozes here is simpler.
        AlarmScheduler.sharedInstance.cancelSnooze()
    }
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
    
    }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // completionHandler([.alert, .badge, .sound,])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
               didReceive response: UNNotificationResponse,
               withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Bonzei")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

