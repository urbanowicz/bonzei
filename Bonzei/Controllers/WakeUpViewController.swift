//
//  FirstViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class WakeUpViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var setAlarmButton: UIButton!
    @IBOutlet weak var setFirstAlarmButton: UIButton!
    @IBOutlet weak var wakeUpLabel: UILabel!
    @IBOutlet weak var alarmsTable: UITableView!
    
    var alarmsTableDataSource = AlarmsTableDataSource()
    
    private var newAlarm: Alarm?
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func setupAlarmsTable() {
            func addTapGestureRecognizerToAlarmsTable() {
                let tapGestureRecognizer = UITapGestureRecognizer()
                tapGestureRecognizer.delegate = self
                tapGestureRecognizer.addTarget(self,action:#selector(WakeUpViewController.alarmsTableTapped(recognizer:)))
                alarmsTable.addGestureRecognizer(tapGestureRecognizer)
            }
            
            alarmsTable.dataSource = alarmsTableDataSource
            addTapGestureRecognizerToAlarmsTable()
        }
        
        setupAlarmsTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /// Inserts an alarm into the 'AlarmsTable'
        func insert(alarm: Alarm?, into table:UITableView) {
                alarmsTable.beginUpdates()
                alarmsTable.insertRows(at: [IndexPath(item: 0, section: 0)],
                                       with: UITableView.RowAnimation.top)
                alarmsTable.endUpdates()
        }
        
        // if new alarm was set:
        // 1. persist it
        // 2. display it
        if newAlarm != nil {
            alarmsTableDataSource.alarms.insert(newAlarm!, at: 0)
            insert(alarm: newAlarm!, into: alarmsTable)
            newAlarm = nil
        }
    }

    // MARK: - Actions

    
    @IBAction func toggleAlarm(_ sender: UISwitch) {
        
        // One of the super views of the 'ui switch' must be an'AlarmsTableCell'. Find it.
        var v = sender.superview
        while ((v as? AlarmsTableCell) == nil && v != nil) {
            v = v!.superview
        }
        
        // cell - the AlarmsTableCell that was toggled
        if let cell = v as? AlarmsTableCell {
            let i = alarmsTable.indexPath(for: cell)!.row
            alarmsTableDataSource.alarms[i].isActive.toggle()
            cell.alarm = alarmsTableDataSource.alarms[i]
        }
    }
    
    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "NewAlarm", sender: self)
    }
    
    //MARK: - Gestures
    
    /// Handles tap gestures on the 'AlarmsTable'.
    /// - A user will tap on a row in the 'AlarmsTable' to edit an alarm.
    /// - When a cell in the 'AlarmsTable' is tapped a segue to 'SetAlarmViewController' must be performed.
    /// - 'SetAlarmViewController' handles the editing of the alarm.
    /// - When the user is done editing the alarm, 'WakeUpViewController' must update and display the relevant row in the 'AlarmsTable'
    @IBAction func alarmsTableTapped(recognizer: UITapGestureRecognizer) {
        if let alarmIndex = alarmsTable.indexPathForRow(at: recognizer.location(in: alarmsTable))?.row {
            print("Edit Alarm: \(alarmsTableDataSource.alarms[alarmIndex])")
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "NewAlarm" {
            let setAlarmViewController = segue.destination as! SetAlarmViewController
            setAlarmViewController.request = .newAlarm
        }
    }
    
    @IBAction func unwindSaveAlarm(_ unwindSegue: UIStoryboardSegue) {
        let setAlarmViewControler = unwindSegue.source as! SetAlarmViewController
        if (setAlarmViewControler.request == .newAlarm) {
            self.newAlarm = setAlarmViewControler.newAlarm
        }
    }
}

/// A custom cell for the 'Alarms Table'
/// Note: It should live in a separate file (eg. Views/AlarmsTableCell.swift) but for some reason 'Assistant Editor' didn't allow me to connect outlets if the class weren't here.
class AlarmsTableCell: UITableViewCell {
    @IBInspectable var activeColor: UIColor = UIColor.black
    @IBInspectable var disabledColor: UIColor = UIColor.systemGray
    @IBInspectable var kern: Float = 20.0
    
    var alarm: Alarm! {
        didSet {
            timeLabel.text = alarm.dateString
            melodyLabel.text = "\u{266A} " + alarm.melodyName
            let s = NSMutableAttributedString(string: "MTWTFSS")
            s.addAttribute(.kern, value: kern, range: NSRange(location: 0, length: s.length))
            if self.alarm.isActive {
                
                //Set color for each day of the week depending on whether it was picked or not
                for i in 0...6 {
                    if alarm.repeatOn.contains(i) {
                        s.addAttribute(.foregroundColor, value: activeColor, range: NSRange(location: i, length: 1))
                    } else {
                        s.addAttribute(.foregroundColor, value: disabledColor, range: NSRange(location: i, length: 1))
                    }
                }
                repeatOnLabel.attributedText = s
                timeLabel.textColor = activeColor
                melodyLabel.textColor = activeColor

            } else {
                s.addAttribute(.foregroundColor, value: disabledColor, range: NSRange(location:0, length: s.length))
                repeatOnLabel.attributedText = s
                timeLabel.textColor = disabledColor
                melodyLabel.textColor = disabledColor
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBOutlet weak var repeatOnLabel: UILabel!
    @IBOutlet weak var melodyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
}
