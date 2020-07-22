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
    
    @IBOutlet weak var noAlarmsVStack: UIStackView!
    
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
        
        if AlarmScheduler.sharedInstance.allAlarms().count == 0 {
            showSetFirstAlarmViews()
        } else {
            hideSetFirstAlarmViews()
        }
        
        alarmsTable.dataSource = alarmsTableDataSource
        alarmsTable.delegate = self 
        alarmsTable.backgroundColor = BonzeiColors.offWhite
        addTapGestureRecognizerToAlarmsTable()
        
        setupWakeUpLabel()
        
        setupAlarmsLabel()
        
        registerForAlarmTriggeredNotification()
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
    
    @IBAction func setFirstAlarmButtonPressed(_ sender: UIButton) {
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
            
            if AlarmScheduler.sharedInstance.allAlarms().count == 0 {
                self.showSetFirstAlarmViews()
            }
            
            complete(true)
        }
        
        deleteAction.backgroundColor = BonzeiColors.red
        deleteAction.title = nil
        deleteAction.image = UIImage(named: "bin")
        
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
            if AlarmScheduler.sharedInstance.allAlarms().count == 0 {
                hideSetFirstAlarmViews()
            }
            let newAlarm = setAlarmViewControler.newAlarm
            AlarmScheduler.sharedInstance.schedule(alarm: newAlarm!)
            HeartBeatService.sharedInstance.start()
            alarmsTable.reloadData()
            
        case .editExistingAlarm:
            let editedAlarm = setAlarmViewControler.alarmToEdit!
            selectedCell!.alarm = editedAlarm
            AlarmScheduler.sharedInstance.updateAlarm(withId: editedAlarm.id, using: editedAlarm)
            alarmsTable.reloadData()
            HeartBeatService.sharedInstance.start()
        }
        
    }
    
    /// Called when a user cancels editing in 'SetAlarmView'
    @IBAction func unwindCancel(_ unwindSegue: UIStoryboardSegue) {
        //nothing to do here.
    }
    
    //MARK: - Private API
    
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
    
    private func findSuperviewThatIsAnAlarmsTableCell(for childView: UIView) -> AlarmsTableCell? {
        var v = childView.superview
        while ((v as? AlarmsTableCell) == nil && v != nil) {
            v = v!.superview
        }
        return v as? AlarmsTableCell
    }
    
    private func hideSetFirstAlarmViews() {
        noAlarmsVStack.isHidden = true
        alarmsLabel.isHidden = false
    }
    
    private func showSetFirstAlarmViews() {
        noAlarmsVStack.isHidden = false
        alarmsLabel.isHidden = true
    }
}

// MARK:- AlarmsTableCell

/// A custom cell for the 'Alarms Table'
class AlarmsTableCell: UITableViewCell {
    
    var alarm: Alarm! {
        didSet {
            setupTimeLabel()
            setupMelodyLabel()
            setupIsActiveSwitch()
            setupRepeatOnLabel()

            self.setNeedsDisplay()
        }
    }
    
    @IBOutlet weak var repeatOnLabel: UILabel!
    
    @IBOutlet weak var melodyLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var isActiveSwitch: UISwitch!
    
    internal func setupViews() {

    }
    
    private func setupTimeLabel() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = alarm.date.timeZone
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        var foregroundColor = BonzeiColors.darkGrayDisabled
        
        if alarm.isActive {
            foregroundColor = BonzeiColors.darkTextColor
        }
        
        let timeString = NSMutableAttributedString(string: dateFormatter.string(from: alarm.date))
        
        timeString.addAttributes([.font: UIFont(name: "Muli-SemiBold", size: 40)!, .foregroundColor: foregroundColor], range: NSRange(location: 0, length: timeString.length))
        
        if !shouldUse24HourMode() {
            timeString.addAttribute(.font, value: UIFont(name: "Muli-SemiBold", size: 16)!,
                                    range: NSRange(location: timeString.length - 2, length: 2))
        }
        timeLabel.attributedText = timeString
    }
    
    private func setupMelodyLabel() {
        melodyLabel.text = "\u{266A}  " + alarm.melodyName
        
        if alarm.isActive {
            melodyLabel.textColor = BonzeiColors.darkGray
        } else {
            melodyLabel.textColor = BonzeiColors.darkGrayDisabled
        }
    }
    
    private func setupIsActiveSwitch() {
        isActiveSwitch.onTintColor = BonzeiColors.gray
        
        if alarm.isActive {
            isActiveSwitch.isOn = true
            isActiveSwitch.thumbTintColor = BonzeiColors.jungleGreen
        } else {
            isActiveSwitch.thumbTintColor = UIColor.white
            isActiveSwitch.isOn = false
        }
    }
    
    private func setupRepeatOnLabel() {
        let s = NSMutableAttributedString(string: "MTWTFSS")
        
        s.addAttribute(.kern, value: 20, range: NSRange(location: 0, length: s.length))
        
        if self.alarm.isActive {
            
            for i in 0...6 {
                if alarm.repeatOn.contains(i) {
                    s.addAttribute(.foregroundColor, value: BonzeiColors.darkTextColor, range: NSRange(location: i, length: 1))
                } else {
                    s.addAttribute(.foregroundColor, value: BonzeiColors.darkGrayDisabled, range: NSRange(location: i, length: 1))
                }
            }

        } else {
            s.addAttribute(.foregroundColor, value: BonzeiColors.darkGrayDisabled, range: NSRange(location:0, length: s.length))
        }
        
        repeatOnLabel.attributedText = s
    }
}
