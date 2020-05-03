//
//  SetMelodyViewController.swift
//  Bonzei
//
//  Created by Tomasz on 20/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SetMelodyViewController: UIViewController {
    
    /// Data source for the `melodiesTable`
    var melodiesTableDataSource = MelodiesTableDataSource()
    
    /// After a user has chosen a melody, the melodie's name will be stored here
    var selectedMelody:String?
    
    /// A back button. Initiates a transition back to `SetAlarmViewController`
    @IBOutlet weak var backButton: UIButton!
    
    /// A table with names of available melodies.
    @IBOutlet weak var melodiesTable: UITableView!
    
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        backButton.backgroundColor = UIColor.clear
        melodiesTable.dataSource = melodiesTableDataSource 
    
    }
    
    // MARK: - Navigation

    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        if let selectedRowIndex = melodiesTable.indexPathForSelectedRow {
            let selectedCell = melodiesTable.cellForRow(at: selectedRowIndex)!
            selectedMelody = selectedCell.textLabel!.text!
        }
        
        performSegue(withIdentifier: "UnwindSetMelody", sender: self)
        
    }
    
    //MARK: - Actions
    /// Start or stop a preview of a melody
    @IBAction func playButtonPressed(_ sender: UIButton) {
        print("Play button pressed")
    }
    
}

/// A custom `UITableViewCell` for the `melodiesTable`
class MelodyCell: UITableViewCell {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var melodyNameLabel: UILabel!
    
    var melodyName: String? {
        get {
            return melodyNameLabel.text
        }
    }
}
