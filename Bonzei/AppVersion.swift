//
//  AppVersion.swift
//  Bonzei
//
//  Created by Tomasz on 04/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import os.log

let APP_VERSION:Int64 = 3

class AppVersionService {
    
    static let sharedInstance = AppVersionService()
    
    private var log = OSLog(subsystem: "Learn", category: "AppVersionService")
    
    private var viewContext: NSManagedObjectContext!
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
    }
    
    public func getAppVersionInstalledOnDevice() -> Int64? {
        let appRecords = fetchMangedAppRecords()
        return appRecords?.first?.version
    }
    
    public func updateAppVersion(to appVersion: Int64) {
        let appRecords = fetchMangedAppRecords()
        
        appRecords?.forEach() { appRecord in viewContext.delete(appRecord)}
        
        let appRecord = ManagedApp(context: viewContext)
        appRecord.version = appVersion
        
        commit()
    }
    
    private func fetchMangedAppRecords() -> [ManagedApp]? {
        let fetchRequest = NSFetchRequest<ManagedApp>(entityName: "ManagedApp")

        var appRecords: [ManagedApp]?

        do {
            appRecords = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            os_log("Failed to fetch App information from db: %{public}s", log: log, type: .error, error.localizedDescription)
        }

        return appRecords
    }
    
    private func commit() {
        do {
            try viewContext.save()
        } catch let error as NSError {
            os_log("Failed to commit changes: %{public}s", log: log, type: .error, error.localizedDescription)
        }
    }
}
