//
//  MelodyTableDatasource.swift
//  Bonzei
//
//  Created by Tomasz on 21/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class MelodiesTableDataSource: NSObject, UITableViewDataSource {
    var melodies = ["Ambient Sea Waves",
                    "Emerald Mountains",
                    "Endorphin Birds",
                    "Forset Light Rays",
                    "Midnight Moon"]
    
    let cellReuseId = "melodiesTableCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return melodies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId)!
        cell.textLabel!.text = melodies[indexPath.row]
        return cell
    }
}
