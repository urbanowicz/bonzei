//
//  FirstViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class WakeUpViewController: UIViewController {
    
    @IBOutlet weak var setAlarmButton: UIButton!
    @IBOutlet weak var setFirstAlarmButton: UIButton!
    @IBOutlet weak var wakeUpLabel: UILabel!
    @IBOutlet weak var alarmsTable: UITableView!
    var alarmsTableDataSource = AlarmsTableDataSource()
    private var newAlarm: Alarm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmsTable.dataSource = alarmsTableDataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if newAlarm != nil {
            alarmsTableDataSource.alarms.insert(newAlarm!, at: 0)
            alarmsTable.beginUpdates()
            alarmsTable.insertRows(at: [IndexPath(item: 0, section: 0)],
                                   with: UITableView.RowAnimation.top)
            alarmsTable.endUpdates()
            newAlarm = nil
        }
    }

    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {

    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier! == "WakeUpToSetAlarmSegue" {
            
        }
    }
    
    @IBAction func unwindSaveAlarm(_ unwindSegue: UIStoryboardSegue) {
        let src = unwindSegue.source as! SetAlarmViewController
        self.newAlarm = src.newAlarm
    }
}

/// A custom cell for the 'Alarms Table'
/// Note: It should live in a separate file (eg. Views/AlarmsTableCell.swift) but for some reason 'Assistant Editor' didn't allow me to connect outlets if the class weren't here.
class AlarmsTableCell: UITableViewCell {
   
    @IBOutlet weak var melodyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}
