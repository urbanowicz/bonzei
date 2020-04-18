//
//  SetAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SetAlarmViewController: UIViewController {
    
    var newAlarm:String?
    
    //A standard date picker. Not customizable. Need to be replaced with a custom widget.
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm")
        dateFormatter.locale = Locale(identifier: "en_US")
        newAlarm = dateFormatter.string(from: datePicker.date)
        performSegue(withIdentifier: "unwindSaveAlarmSegue", sender: self) 
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
