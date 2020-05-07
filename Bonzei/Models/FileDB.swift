//
//  FileDB.swift
//  Bonzei
//
//  Created by Tomasz on 17/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

///Persists an object in user's document directory.
///
///Returns: 'true' if operation was successful. Otherwise 'false'.
func fileDbWrite(fileName: String, object: Any) -> Bool {
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
        try data.write(to: documentPathFor(fileName))
        return true
    } catch {
        print("In fileDbWrite: \(error.localizedDescription)")
    }
    return false
}

///Reads an object from user's document directory.
///
///Returns: the object if operation was successful. nil otherwise
func fileDbRead(fileName: String) -> Any? {
    do {
        let data = try Data(contentsOf: documentPathFor(fileName))
        let object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
        return object
    } catch {
        print("In fileDbRead: \(error.localizedDescription)")
    }
    return nil
}

func fileDbDelete(fileName: String) {
    do {
        try FileManager.default.removeItem(atPath: documentPathFor(fileName).path)
    } catch let error {
        print(error.localizedDescription)
    }
}

fileprivate func documentPathFor(_ fileName: String) -> URL {
    let a = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return a[0].appendingPathComponent(fileName)
}
