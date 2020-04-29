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
        
        //1. AlarmsTable
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
        if newAlarm != nil {
            alarmsTableDataSource.alarms.insert(newAlarm!, at: 0)
            alarmsTable.beginUpdates()
            alarmsTable.insertRows(at: [IndexPath(item: 0, section: 0)],
                                   with: UITableView.RowAnimation.top)
            alarmsTable.endUpdates()
            newAlarm = nil
        }
    }

    // MARK: - Actions
    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {

    }
    
    @IBAction func toggleAlarm(_ sender: UISwitch) {
        
        //One of the super views of the 'ui switch' must be an'AlarmsTableCell'. Find it.
        var v = sender.superview
        while ((v as? AlarmsTableCell) == nil && v != nil) {
            v = v!.superview
        }
        
        //cell - the AlarmsTableCell that was toggled
        if let cell = v as? AlarmsTableCell {
            let i = alarmsTable.indexPath(for: cell)!.row
            alarmsTableDataSource.alarms[i].isActive.toggle()
            cell.alarm = alarmsTableDataSource.alarms[i]
        }
    }
    
    //MARK: - Gestures
    @IBAction func alarmsTableTapped(recognizer: UITapGestureRecognizer) {
        if let alarmIndex = alarmsTable.indexPathForRow(at: recognizer.location(in: alarmsTable))?.row {
            print(alarmsTableDataSource.alarms[alarmIndex])
        }
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
