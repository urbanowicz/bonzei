//
//  PowerNapPersistenceService.swift
//  Bonzei
//
//  Created by Tomasz on 02/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

import CoreData
import UIKit
import os.log

/// Provides CRUD operations for `PowerNap` objects  stored in local db
class PowerNapPersistenceService {
    
    static let sharedInstance = PowerNapPersistenceService()
    
    private let powerNapEntityName = "ManagedPowerNap"
    
    private var viewContext: NSManagedObjectContext!
    
    private var log = OSLog(subsystem: "Powermode", category: "PowerNapPersistenceService")
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Public API
    
    /// Stores a power nap in  the local db
    /// - Parameter powerNap: a power nap to be saved in the local db
    public func create(powerNap: PowerNap) {
        guard fetchManagedPowerNap(powerNapId: powerNap.id) == nil else { return }
        
        let managedPowerNap = ManagedPowerNap(context: viewContext)
        
        copyValues(from: powerNap, to: managedPowerNap)
        commit()
    }
    
    /// Reads a powerNap from the local db
    /// - Parameter powerNapId: unique id of the power nap to be read from the local db
    /// - Returns: Power nap  given by `powerNapId` or `nil` if no such nap exists
    public func read(powerNapId: String) -> PowerNap? {
        guard let managedPowerNap = fetchManagedPowerNap(powerNapId: powerNapId) else { return nil }
        
        return convertToPowerNap(managedPowerNap: managedPowerNap)
    }
    
    /// Reads all power naps from the local db
    /// - Returns: all power naps stored in the local db or `nil` if there are no naps in the l db.
    public func readAll() -> [PowerNap]? {
        guard let managedPowerNaps = fetchAllManagedPowerNaps() else { return nil }
        guard managedPowerNaps.count > 0 else { return nil }
        
        let powerNaps: [PowerNap] = managedPowerNaps.map() { convertToPowerNap(managedPowerNap: $0) }
        
        return powerNaps
    }
    
    /// Updates a power nap stored in the local db.
    /// The way this operation works is that a power nap with `powerNap.id` is first fetched from the db and then its values are updated to
    /// values present in the `PowerNap`  that was passed as a parameter.
    /// If the local db doesn't contain a power nap with id = `powerNap.id` this method does nothing. (ie. no error is raised)
    /// - Parameter powerNap: a power nap to be updated.
    public func update(powerNap: PowerNap) {
        guard let managedPowerNap = fetchManagedPowerNap(powerNapId: powerNap.id) else { return }
        
        copyValues(from: powerNap, to: managedPowerNap)
        commit()
    }
    
    /// Removes a powerNap from the local db
    /// - Parameter powerNapId: id of the power nap that you wish to dlelete from the local db.
    public func delete(powerNapId: String) {
        guard let managedPowerNap = fetchManagedPowerNap(powerNapId: powerNapId) else { return }
        
        viewContext.delete(managedPowerNap)
        commit()
    }
    
    public func deleteAll() {
        let managedPowerNaps = fetchAllManagedPowerNaps()
        managedPowerNaps?.forEach() { viewContext.delete($0) }
        
        commit()
    }
    
    // MARK: - Private API
    
    private func commit() {
        do {
            try viewContext.save()
        } catch let error as NSError {
            os_log("Failed to commit changes: %{public}s", log: log, type: .error, error.localizedDescription)
        }
    }
    
    private func fetchManagedPowerNap(powerNapId id: String) -> ManagedPowerNap? {
        let fetchRequest = NSFetchRequest<ManagedPowerNap>(entityName: powerNapEntityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        var managedPowerNaps: [ManagedPowerNap]?
        
        do {
            managedPowerNaps = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            os_log("Failed to fetch a power nap object from local db: %{public}s", log: log, type: .error, error.localizedDescription)
        }
        
        return managedPowerNaps?.first
    }
    
    private func fetchAllManagedPowerNaps() -> [ManagedPowerNap]? {
        let fetchRequest = NSFetchRequest<ManagedPowerNap>(entityName: powerNapEntityName)
        
        var managedPowerNaps: [ManagedPowerNap]?
        
        do {
            managedPowerNaps = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            os_log("Failed to fetch all power nap objects from local db: %{public}s", log: log, type: .error, error.localizedDescription)
        }
        
        return managedPowerNaps
    }
    
    private func convertToPowerNap(managedPowerNap: ManagedPowerNap) -> PowerNap {
        let powerNap = PowerNap(id: managedPowerNap.id!,
                              melodyName:  managedPowerNap.melodyName!,
                              alarmMelodyName: managedPowerNap.alarmMelodyName!,
                              description: managedPowerNap.about!,
                              creationDate: managedPowerNap.creationDate!)
        
        return powerNap
    }
    
    private func copyValues(from powerNap: PowerNap, to managedPowerNap: ManagedPowerNap) {
        managedPowerNap.id = powerNap.id
        managedPowerNap.melodyName = powerNap.melodyName
        managedPowerNap.alarmMelodyName = powerNap.alarmMelodyName
        managedPowerNap.about = powerNap.description
        managedPowerNap.creationDate = powerNap.creationDate
    }

}
