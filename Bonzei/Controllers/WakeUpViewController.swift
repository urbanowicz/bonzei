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
    
    /// A data source for the alarms table.
    var alarmsTableDataSource = AlarmsTableDataSource()
    
    /// Alarm table cell that a user last tapped or selected in the table.
    var selectedCell: AlarmsTableCell?
    
    /// If  a new alarm has been created by the 'SetAlarmViewController' this variable will hold the new alarm.
    /// This is needed so that this controller can:
    /// - insert the alarm into 'UIViewTable',
    /// - store the alarm in the model,
    /// - persist the alarm in 'FileDb'.
    var newAlarm: Alarm?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        alarmsTable.dataSource = alarmsTableDataSource
        alarmsTable.backgroundColor = UIColor.white
        addTapGestureRecognizerToAlarmsTable()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // if new alarm was added, insert a row into alarmsTable
        if newAlarm != nil {
            insertRowIntoAlarmsTable()
            newAlarm = nil
        }
        
    }

    // MARK: - Actions
    
    @IBAction func toggleAlarm(_ alarmIsActiveSwitch: UISwitch) {
        
        // cell - the AlarmsTableCell that was toggled
        if let cell = findSuperviewThatIsAnAlarmsTableCell(for: alarmIsActiveSwitch) {
            cell.alarm.isActive.toggle()
            AlarmScheduler.sharedInstance.updateAlarm(withId: cell.alarm.id, using: cell.alarm)
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
        if let selectedIndexPath = alarmsTable.indexPathForRow(at: recognizer.location(in: alarmsTable)) {
            selectedCell = alarmsTable.cellForRow(at: selectedIndexPath) as? AlarmsTableCell
            performSegue(withIdentifier: "EditExistingAlarm", sender: self)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "NewAlarm" {
            let setAlarmViewController = segue.destination as! SetAlarmViewController
            setAlarmViewController.request = .newAlarm
        }
        
        if segue.identifier! == "EditExistingAlarm" {
            let setAlarmViewController = segue.destination as! SetAlarmViewController
            setAlarmViewController.request = .editExistingAlarm
            setAlarmViewController.alarmToEdit = selectedCell!.alarm
        }
    }
    
    @IBAction func unwindSaveAlarm(_ unwindSegue: UIStoryboardSegue) {
        let setAlarmViewControler = unwindSegue.source as! SetAlarmViewController
        switch setAlarmViewControler.request {
        case .newAlarm :
            self.newAlarm = setAlarmViewControler.newAlarm
            AlarmScheduler.sharedInstance.schedule(alarm: newAlarm!)
            HeartBeatService.sharedInstance.start()
            
        case .editExistingAlarm:
            let editedAlarm = setAlarmViewControler.alarmToEdit!
            selectedCell!.alarm = editedAlarm
            HeartBeatService.sharedInstance.start()
            AlarmScheduler.sharedInstance.updateAlarm(withId: editedAlarm.id, using: editedAlarm)
        }
    }
    
    @IBAction func unwindCancel(_ unwindSegue: UIStoryboardSegue) {
        //nothing to do here.
    }
    
    //MARK: - Helper functions
    
    private func addTapGestureRecognizerToAlarmsTable() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self,action:#selector(WakeUpViewController.alarmsTableTapped(recognizer:)))
        alarmsTable.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// Inserts a row into 'AlarmsTable'. Called after adding a new alarm to `AlarmScheduler`
    private func insertRowIntoAlarmsTable() {
        alarmsTable.beginUpdates()
        alarmsTable.insertRows(at: [IndexPath(item: 0, section: 0)],
                               with: UITableView.RowAnimation.top)
        alarmsTable.endUpdates()
    }
    
    private func findSuperviewThatIsAnAlarmsTableCell(for childView: UIView) -> AlarmsTableCell? {
        var v = childView.superview
        while ((v as? AlarmsTableCell) == nil && v != nil) {
            v = v!.superview
        }
        return v as? AlarmsTableCell
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

            isActiveSwitch.onTintColor = UIColor(red: 0.93, green: 0.91, blue: 0.95, alpha: 1.00)
            
            timeLabel.text = alarm.dateString
            melodyLabel.text = "\u{266A} " + alarm.melodyName
            let s = NSMutableAttributedString(string: "MTWTFSS")
            s.addAttribute(.kern, value: kern, range: NSRange(location: 0, length: s.length))
            if self.alarm.isActive {
                
                isActiveSwitch.isOn = true
                isActiveSwitch.thumbTintColor = BonzeiColors.green
                
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
                isActiveSwitch.thumbTintColor = UIColor.white
                isActiveSwitch.isOn = false
                
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
    @IBOutlet weak var isActiveSwitch: UISwitch!
    
}
