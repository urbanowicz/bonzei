//
//  MelodyTableDatasource.swift
//  Bonzei
//
//  Created by Tomasz on 21/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class MelodiesTableDataSource: NSObject, UITableViewDataSource {
    
    let cellReuseId = "MelodiesTableCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return melodies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as! MelodyCell
        cell.melodyNameLabel.text = melodies[indexPath.row]
        return cell
    }
    
}
