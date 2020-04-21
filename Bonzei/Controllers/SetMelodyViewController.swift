//
//  SetMelodyViewController.swift
//  Bonzei
//
//  Created by Tomasz on 20/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SetMelodyViewController: UIViewController {
    var melodiesTableDataSource = MelodiesTableDataSource()
    var selectedMelody:String?
    
    @IBOutlet weak var melodiesTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        melodiesTable.dataSource = melodiesTableDataSource 
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if let selectedRowIndex = melodiesTable.indexPathForSelectedRow {
            let selectedCell = melodiesTable.cellForRow(at: selectedRowIndex)!
            selectedMelody = selectedCell.textLabel!.text!
        }
        performSegue(withIdentifier: "UnwindSetMelody", sender: self)
    }
}
