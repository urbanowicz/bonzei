//
//  SetMelodyViewController.swift
//  Bonzei
//
//  Created by Tomasz on 20/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import AVFoundation

class SetMelodyViewController: UIViewController {
    
    /// Data source for the `melodiesTable`
    var melodiesTableDataSource = MelodiesTableDataSource()
    
    /// Delegate for the `melodiesTable`
    var melodiesTableDelegate = MelodiesTableDelegate()
    
    /// After a user has chosen a melody, the melodie's name will be stored here
    var selectedMelody:String?
    
    /// Audio player used for previewing melodies
    var audioPlayer: AVAudioPlayer?
    
    /// Table index of the melody that is currently being previewd by a user
    ///
    /// If no melody is being previewed it set to `nil`
    /// If a melody is being previewed then below code will return the relevant `MelodyCell`:
    ///
    ///     melodiesTable.cellForRow(at: IndexPath(row: indexOfCurrentlyPlayingMelody, section: 0))
    ///
    ///
    var indexOfCurrentlyPlayingMelody: Int?
    
    /// A back button. Initiates a transition back to `SetAlarmViewController`
    @IBOutlet weak var backButton: UIButton!
    
    /// A table with names of available melodies.
    @IBOutlet weak var melodiesTable: UITableView!
    
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        backButton.backgroundColor = UIColor.clear
        melodiesTable.dataSource = melodiesTableDataSource
        melodiesTable.delegate = melodiesTableDelegate
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        indexOfCurrentlyPlayingMelody = nil
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
        }
    }
    
    // MARK: - Navigation

    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        if let selectedRowIndex = melodiesTable.indexPathForSelectedRow {
            let selectedCell = melodiesTable.cellForRow(at: selectedRowIndex) as! MelodyCell
            selectedMelody = selectedCell.melodyName
        }
        
        performSegue(withIdentifier: "UnwindSetMelody", sender: self)
        
    }
    
    //MARK: - Actions
    /// Start or stop a preview of a melody
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        // Find the table cell for the melody we need to preview
        var view = sender.superview
        while view as? MelodyCell == nil {
            view = view!.superview
        }
        
        // A table cell for the melody we need to preview
        let selectedCell = view as! MelodyCell
        
        // An index for the melody we need to preview
        let selectedMelodyIndex = melodiesTable.indexPath(for: selectedCell)!.row
        
        // Check if there is a melody being played now
        if indexOfCurrentlyPlayingMelody != nil {
            
            audioPlayer!.stop()
            
            let currentlyPlayingCell =
                melodiesTable.cellForRow(at: IndexPath(row: indexOfCurrentlyPlayingMelody!, section: 0)) as! MelodyCell
            
            currentlyPlayingCell.isPlaying = false
            indexOfCurrentlyPlayingMelody = nil
            
            if selectedCell == currentlyPlayingCell {
                return
            }
        
        }

        // Play the selected melody
        if let path = Bundle.main.path(forResource: selectedCell.melodyName! + ".mp3", ofType: nil) {
            
            let url = URL(fileURLWithPath: path)
            
            indexOfCurrentlyPlayingMelody = selectedMelodyIndex
            selectedCell.isPlaying = true
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()

            } catch {
                print("Playing a melody failed. \"\(selectedCell.melodyName!).mp3\"")
                indexOfCurrentlyPlayingMelody = nil
                selectedCell.isPlaying = false
            }
            
        } else {
            print("Couldn't preview a melody because the sound file was not found: \"\(selectedCell.melodyName!).mp3\"")
        }
        
    }
    
}

/// A custom `UITableViewCell` for the `melodiesTable`
class MelodyCell: UITableViewCell {
    
    /// Indicates whether a user has picked this melody by selecting a corresponding row in the table
    var isPicked = false {
        didSet {
            if isPicked {
                checkMarkLabel.text = "\u{2713}"
                checkMarkLabel.isHidden = false
            } else {
                checkMarkLabel.isHidden = true
            }
            setNeedsDisplay()
        }
    }
    
    /// Indicates whether this melody is currently being previewed
    var isPlaying = false {
        didSet {
            if isPlaying {
                playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            } else {
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            setNeedsDisplay()
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var melodyNameLabel: UILabel!
    @IBOutlet weak var checkMarkLabel: UILabel!
    
    /// A name of the melody that is displayed in this cell
    var melodyName: String? {
        get {
            return melodyNameLabel.text
        }
    }
}

/// A delegate for the table that displays names of melodies
class MelodiesTableDelegate: NSObject, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MelodyCell
        cell.isPicked = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MelodyCell
        cell.isPicked = false
    }
}
