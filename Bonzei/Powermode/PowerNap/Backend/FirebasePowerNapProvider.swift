//
//  FirebasePowerNapsProvider.swift
//  Bonzei
//
//  Created by Tomasz on 02/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import os.log
import Firebase

class FirebasePowerNapProvider {
    
    static let sharedInstance = FirebasePowerNapProvider()
    
    /// Firebase firestore
    private let firestore = Firestore.firestore()
    
    /// Firebase cloud storage
    private let storage = Storage.storage()
    
    private var log = OSLog(subsystem: "Powermode", category: "FirebasePowerNapProvider")
    
    private init() {
        
    }
    
    func syncWithBackend(completionHandler: @escaping ()->Void) {
        firestore
            .collection("power_naps")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    os_log("Failed to get power naps from Firestore db: %{public}s", log: self.log, type: .error, err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        guard let powerNap = self.convertToPowerNap(document: document) else { continue }
                        print(powerNap)
                    }
                }
                DispatchQueue.main.async {
                    completionHandler()
                }
        }
    }
    
    private func convertToPowerNap(document: DocumentSnapshot) -> PowerNap? {
        guard var dictionary = document.data() else { return nil }
        dictionary["creationDate"] = (dictionary["creationDate"] as! Timestamp).dateValue()
        dictionary["id"] = document.documentID
        
        return PowerNap(dictionary: dictionary)
    }
}
