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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmScheduler.sharedInstance.allAlarms().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as! AlarmsTableCell
        cell.alarm = AlarmScheduler.sharedInstance.allAlarms()[indexPath.row]
        return cell
    }
}
