//
//  FirstViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class WakeUpViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate {
    
    @IBOutlet weak var setAlarmButton: UIButton!
    
    @IBOutlet weak var setFirstAlarmButton: UIButton!
    
    @IBOutlet weak var wakeUpLabel: UILabel!
    
    @IBOutlet weak var alarmsLabel: UILabel!
    
    @IBOutlet weak var alarmsTable: UITableView!
    
    /// A data source for the alarms table.
    var alarmsTableDataSource = AlarmsTableDataSource()
    
    /// Alarm table cell that a user last tapped or selected in the table.
    var selectedCell: AlarmsTableCell?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmsTable.dataSource = alarmsTableDataSource
        alarmsTable.delegate = self 
        alarmsTable.backgroundColor = BonzeiColors.offWhite
        addTapGestureRecognizerToAlarmsTable()
        
        setupWakeUpLabel()
        
        setupAlarmsLabel()
        
        registerForAlarmTriggeredNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopReceivingAlarmTriggeredNotification()
    }
    
    // MARK: - Actions
    
    /// Called when a user activates or deactivates an alarm with a ui switch
    @IBAction func toggleAlarm(_ alarmIsActiveSwitch: UISwitch) {
        // cell - the AlarmsTableCell that was toggled
        if let cell = findSuperviewThatIsAnAlarmsTableCell(for: alarmIsActiveSwitch) {
            cell.alarm.isActive.toggle()
            AlarmScheduler.sharedInstance.updateAlarm(withId: cell.alarm.id, using: cell.alarm)
        }
    }
    
    @IBAction func dumpRequested(_ sender: Any) {
        AlarmScheduler.sharedInstance.dump()
        AlarmScheduler.sharedInstance.dumpNotifications()
    }
    /// Called when a user presses the '+' button to add a new alarm
    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "NewAlarm", sender: self)
    }
    
    @objc func didTriggerAlarm(_ notification: Notification) {
        let userInfo = notification.userInfo as! [String: Any]
        let alarm = userInfo["alarm"] as! Alarm
       
        // If it is a 'one time' alarm that has triggered, AlarmScheduler has changed its state to inactive.
        // This is because we don't want a 'one time' alarm to go off the next day.
        // To reflect the change from active to inactive in the UI we need to refresh the alarmsTable
        if  !alarm.isRecurring {
            alarmsTable.reloadData()
        }
    }
    
    // MARK: - Alarms Table Delegate
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
            let alarmCell = tableView.cellForRow(at: indexPath) as! AlarmsTableCell
            
            AlarmScheduler.sharedInstance.unscheduleAlarm(withId: alarmCell.alarm.id)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            complete(true)
        }
        
        deleteAction.backgroundColor = BonzeiColors.gray
        deleteAction.title = nil
        deleteAction.image = UIImage(systemName: "bin.xmark")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let alarmsTableCell = cell as! AlarmsTableCell
        alarmsTableCell.setupViews()
    }
    
    // MARK: - Gestures
    
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
            
            setAlarmViewController.prepareTofulfillRequest(
                withType: .newAlarm,
                forAlarm: nil
            )
        }
        
        if segue.identifier! == "EditExistingAlarm" {
            let setAlarmViewController = segue.destination as! SetAlarmViewController
            
            setAlarmViewController.prepareTofulfillRequest(
                withType: .editExistingAlarm,
                forAlarm: selectedCell!.alarm
            )
        }
    }
    
    /// Called when a user saves an alarm in 'SetAlarmView'.
    @IBAction func unwindSaveAlarm(_ unwindSegue: UIStoryboardSegue) {
        let setAlarmViewControler = unwindSegue.source as! SetAlarmViewController
        
        switch setAlarmViewControler.request {
        case .newAlarm :
            let newAlarm = setAlarmViewControler.newAlarm
            AlarmScheduler.sharedInstance.schedule(alarm: newAlarm!)
            HeartBeatService.sharedInstance.start()
            insertRowIntoAlarmsTable()
            
        case .editExistingAlarm:
            let editedAlarm = setAlarmViewControler.alarmToEdit!
            selectedCell!.alarm = editedAlarm
            AlarmScheduler.sharedInstance.updateAlarm(withId: editedAlarm.id, using: editedAlarm)
            HeartBeatService.sharedInstance.start()
        }
    }
    
    /// Called when a user cancels editing in 'SetAlarmView'
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
    
    
    private func setupWakeUpLabel() {
        guard let muliBoldFont = UIFont(name: "Muli-Bold", size: BonzeiFonts.title.size) else {
            fatalError("""
                Failed to load the "Muli-Bold" font.
                """
            )
        }
        
        wakeUpLabel.font = UIFontMetrics.default.scaledFont(for: muliBoldFont)
        wakeUpLabel.adjustsFontForContentSizeCategory = true
        wakeUpLabel.textColor = BonzeiColors.darkTextColor
    }
    
    private func setupAlarmsLabel() {
        // Color, font and size are set in the storyboard
        
        let text = NSMutableAttributedString(
            string: alarmsLabel.text!)
        
        text.addAttribute(.kern,
                          value: BonzeiFonts.label.character,
                          range: NSRange(location: 0, length: text.length))
        
        alarmsLabel.attributedText = text
    }
    
    private func registerForAlarmTriggeredNotification() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(WakeUpViewController.didTriggerAlarm(_:)),
                name: Notification.Name.didTriggerAlarm,
                object: nil)
    }
    
    private func stopReceivingAlarmTriggeredNotification() {
        NotificationCenter.default.removeObserver(
             self,
             name: .didTriggerAlarm,
             object: nil)
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
    
    @IBInspectable var activeColor: UIColor = BonzeiColors.darkTextColor
    
    @IBInspectable var disabledColor: UIColor = UIColor.systemGray
    
    @IBInspectable var kern: Float = 20.0
    
    var alarm: Alarm! {
        didSet {
            
            setupTimeLabel()
            setupAmLabel()
            setupMelodyLabel()
            
            isActiveSwitch.onTintColor = UIColor(red: 0.93, green: 0.91, blue: 0.95, alpha: 1.00)
            
            melodyLabel.text = "\u{266A} " + alarm.melodyName
            let s = NSMutableAttributedString(string: "MTWTFSS")
            s.addAttribute(.kern, value: kern, range: NSRange(location: 0, length: s.length))
            if self.alarm.isActive {
                
                isActiveSwitch.isOn = true
                isActiveSwitch.thumbTintColor = BonzeiColors.jungleGreen
                
                //Set color for each day of the week depending on whether it was picked or not
                for i in 0...6 {
                    if alarm.repeatOn.contains(i) {
                        s.addAttribute(.foregroundColor, value: activeColor, range: NSRange(location: i, length: 1))
                    } else {
                        s.addAttribute(.foregroundColor, value: disabledColor, range: NSRange(location: i, length: 1))
                    }
                }
                repeatOnLabel.attributedText = s
                melodyLabel.textColor = activeColor

            } else {
                isActiveSwitch.thumbTintColor = UIColor.white
                isActiveSwitch.isOn = false
                
                s.addAttribute(.foregroundColor, value: disabledColor, range: NSRange(location:0, length: s.length))
                repeatOnLabel.attributedText = s
                melodyLabel.textColor = disabledColor
                
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBOutlet weak var repeatOnLabel: UILabel!
    
    @IBOutlet weak var melodyLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var amLabel: UILabel!
    
    @IBOutlet weak var isActiveSwitch: UISwitch!
    
    internal func setupViews() {

    }
    
    private func setupTimeLabel() {
        var foregroundColor = BonzeiColors.darkGrayDisabled
        
        if alarm.isActive {
            foregroundColor = BonzeiColors.darkTextColor
        }
        
        timeLabel.textColor = foregroundColor
        
        var dateString = alarm.dateString
        dateString = String(dateString.prefix(dateString.count - 3))
       
        timeLabel.text = dateString
    }
    
    private func setupAmLabel() {
        var foregroundColor = BonzeiColors.darkGrayDisabled
        
        if alarm.isActive {
            foregroundColor = BonzeiColors.darkTextColor
        }
        
        amLabel.textColor = foregroundColor
        
        amLabel.text = String(alarm.dateString.suffix(2))
    }
    
    private func setupMelodyLabel() {
        if alarm.isActive {
            melodyLabel.textColor = BonzeiColors.darkGray
        } else {
            melodyLabel.textColor = BonzeiColors.darkGrayDisabled
        }
        
    }
}
