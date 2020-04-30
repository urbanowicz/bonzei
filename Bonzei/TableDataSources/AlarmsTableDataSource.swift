//
//  AlarmsTableDataSource.swift
//  Bonzei
//
//  Created by Tomasz on 16/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class AlarmsTableDataSource: NSObject, UITableViewDataSource {
    
    let cellReuseId = "alarmsTableCell"
    
    override init() {
        super.init()
        if let savedAlarms = fileDbRead(fileName: "alarms.db") as? [Alarm] {
            alarms = savedAlarms
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as! AlarmsTableCell
        cell.alarm = alarms[indexPath.row]
        return cell
    }
}
