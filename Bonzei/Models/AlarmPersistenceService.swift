//
//  AlarmPersistenceService.swift
//  Bonzei
//
//  Created by Tomasz on 11/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct NotificationRequest {
    var identifier: String
    var alarmId: String?
}

enum Entities: String {
    case Alarm = "ManagedAlarm"
    case NotificationRequest = "ManagedNotificationRequest"
}

class AlarmPersistenceService {
    
    var viewContext: NSManagedObjectContext!
   
    static let sharedInstance = AlarmPersistenceService()
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
    }
    
    func create(alarm: Alarm) {
        newManagedAlarm(alarm)
        commit()
    }
    
    func readAlarm(withId id: String) -> Alarm? {
        guard let managedAlarm = fetchManagedAlarm(withId: id) else { return nil }
        return convertToAlarm(from: managedAlarm)
    }
    
    func readAllAlarms() -> [Alarm]? {
        if let managedAlarms = fetchAllManagedAlarms() {
            let alarms:[Alarm] = managedAlarms.map() { managedAlarm in
                return convertToAlarm(from: managedAlarm)
            }
            return alarms
        }
        
        return nil
    }
    
    func updateAlarm(withId id: String, using alarm: Alarm) {
        guard let managedAlarm = fetchManagedAlarm(withId: id) else { return }
        
        managedAlarm.setValue(id, forKey: "id")
        setValuesForManagedAlarm(managedAlarm, using: alarm)
        
        commit()
    }
    
    func deleteAlarm(withId id: String) {
        guard let managedAlarm = fetchManagedAlarm(withId: id) else { return }
        
        viewContext.delete(managedAlarm)
        commit()
    }
    
    func deleteAllAlarms() {
        deleteAllFor(Entities.Alarm.rawValue)
        commit()
    }
    
    func createNotificationRequestForAlarm(withId id: String, notificationRequest: NotificationRequest) {
        newManagedNotificationRequest(notificationRequest, forAlarmId: id)
        commit()
    }
    
    func readNotificationRequestsForAlarm(withId id: String) -> [NotificationRequest]? {
        guard let managedAlarm = fetchManagedAlarm(withId: id) else { return nil }
        
        guard let managedNotificationRequests = managedAlarm.notificationRequests else {
            return nil
        }
        
        var notificationRequests = [NotificationRequest]()
        
        for managedRequest in managedNotificationRequests {
            let managedRequest = managedRequest as! ManagedNotificationRequest
            notificationRequests.append(convertToNotificationRequest(from: managedRequest))
        }
        
        return notificationRequests
    }
    
    func readAllNotificationRequests() -> [NotificationRequest]? {
        if let managedRequests = fetchAllManagedNotificationRequests() {
            let notificationRequests:[NotificationRequest]  = managedRequests.map() { request in
                return convertToNotificationRequest(from: request)
            }
            return notificationRequests
        }

        return nil
    }
    
    func deleteNotificationRequestsForAlarm(withId id: String) {
        guard let managedAlarm = fetchManagedAlarm(withId: id) else { return }
        
        guard let managedNotificationRequests = managedAlarm.notificationRequests else {
            return
        }
        
        for element in managedNotificationRequests {
            let managedNotificationRequest = element as! ManagedNotificationRequest
            viewContext.delete(managedNotificationRequest)
        }
        
        commit()
    }
    
    func deleteAllNotificationRequests() {
        self.deleteAllFor(Entities.NotificationRequest.rawValue)
        commit()
    }
    
    //MARK: - Helper functions
    
    private func commit() {
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("AlarmPersistenceService: Could not save. \(error.localizedDescription), \(error.userInfo)")
        }
    }
    
    private func newManagedAlarm(_ alarm: Alarm) {
        let managedAlarm = ManagedAlarm(context: viewContext)
        managedAlarm.id = alarm.id
        setValuesForManagedAlarm(managedAlarm, using: alarm)
    }
    
    private func newManagedNotificationRequest(_ notificationRequest: NotificationRequest, forAlarmId alarmId: String) {
        guard let managedAlarm = fetchManagedAlarm(withId: alarmId) else { return }
        
        let managedRequest = ManagedNotificationRequest(context: viewContext)
        managedRequest.identifier = notificationRequest.identifier
        managedAlarm.addToNotificationRequests(managedRequest)
    }
    
    private func deleteAllFor(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            
            for object in results {
                viewContext.delete(object)
            }

        } catch let error {
            print("AlarmPersistenceService: Detele all data in \(entity) error :", error)
        }
    }
    
    private func prepareFetchRequest(forEntity entity: String, withPredicate predicate: NSPredicate?) -> NSFetchRequest<NSManagedObject> {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    private func convertToAlarm(from managedAlarm: ManagedAlarm) -> Alarm {
        var alarm = Alarm(
            id: managedAlarm.id!,
            date: managedAlarm.date!,
            melodyName: managedAlarm.melodyName!,
            snoozeEnabled: managedAlarm.snoozeEnabled,
            isActive: managedAlarm.isActive,
            lastTriggerDate: managedAlarm.lastTriggerDate)

        let repeatOnString = managedAlarm.repeatOn!

        alarm.repeatOn = Set<Int>()
        repeatOnString.forEach { weekdayChar in
            alarm.repeatOn.insert(weekdayChar.wholeNumberValue!)
        }
        
        return alarm
    }
    
    private func convertToNotificationRequest(from request: ManagedNotificationRequest) -> NotificationRequest {
        let managedAlarm = request.alarm!
        
        let notificationRequest = NotificationRequest(
            identifier: request.identifier!,
            alarmId: managedAlarm.id!
        )
        
        return notificationRequest
    }
    
    private func fetchManagedAlarm(withId id: String) -> ManagedAlarm? {
        let fetchRequest = prepareFetchRequest(
            forEntity: Entities.Alarm.rawValue,
            withPredicate: NSPredicate(format: "id = %@", id))
        
        var managedAlarms: [NSManagedObject]?
        
        do {
            managedAlarms = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("AlarmPersistenceService: Could not fetch alarm with id: \(id). Cause: \(error), \(error.userInfo)")
        }
        
        return managedAlarms?.first as? ManagedAlarm
    }
    
    private func fetchAllManagedAlarms() -> [ManagedAlarm]? {
        let fetchRequest = NSFetchRequest<ManagedAlarm>(entityName: Entities.Alarm.rawValue)
        
        var managedAlarms: [ManagedAlarm]?
        
        do {
            managedAlarms = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("AlarmPersistenceService: Could not fetch alarms. Cause \(error), \(error.userInfo)")
        }
        
        return managedAlarms
    }
    
    private func fetchAllManagedNotificationRequests() -> [ManagedNotificationRequest]? {
        let fetchRequest = NSFetchRequest<ManagedNotificationRequest>(entityName: Entities.NotificationRequest.rawValue)
        
        var managedNotificationRequests: [ManagedNotificationRequest]?
        
        do {
            managedNotificationRequests = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("AlarmPersistenceService: Could not fetch notifications. Cause \(error), \(error.userInfo)")
        }
        
        return managedNotificationRequests
    }
    
    private func setValuesForManagedAlarm(_ managedAlarm: ManagedAlarm, using alarm: Alarm) {
        managedAlarm.melodyName = alarm.melodyName
        managedAlarm.date = alarm.date;
        managedAlarm.isActive = alarm.isActive
        managedAlarm.lastTriggerDate = alarm.lastTriggerDate
        managedAlarm.snoozeEnabled = alarm.snoozeEnabled
        
        let repeatOnStr = alarm.repeatOn
            .reduce("") { result, weekday in
                return "\(result)\(weekday)"
        }
        
        managedAlarm.repeatOn = repeatOnStr
    }
}
