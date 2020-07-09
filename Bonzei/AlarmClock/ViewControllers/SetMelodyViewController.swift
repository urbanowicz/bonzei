//
//  SetMelodyViewController.swift
//  Bonzei
//
//  Created by Tomasz on 20/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import AVFoundation

class SetMelodyViewController: UIViewController, AVAudioPlayerDelegate {
    
    /// After a user has chosen a melody, the melodie's name will be stored here
    var selectedMelody:String?
    
    /// Audio player used for previewing melodies
    var audioPlayer: AVAudioPlayer?
    
    /// Table index of the melody that is currently being previewed by a user
    ///
    /// If no melody is being previewed it set to `nil`
    /// If a melody is being previewed then below code will return the relevant `MelodyCell`:
    ///
    ///     melodiesTable.cellForRow(at: IndexPath(row: indexOfCurrentlyPlayingCell, section: 0))
    ///
    ///
    var indexOfCurrentlyPlayingCell: Int?
    
    /// A back button. Initiates a transition back to `SetAlarmViewController`
    @IBOutlet weak var backButton: UIButton!
    
    /// A table with names of available melodies.
    @IBOutlet weak var melodiesTable: UITableView!
    
    @IBOutlet weak var overlayView: UIView!
    let cellReuseId = "MelodiesTableCell"
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.backgroundColor = UIColor.clear
        
        melodiesTable.dataSource = self
        
        melodiesTable.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if isBeingPresented {
            selectRowFor(melody: selectedMelody!)
        }
        
        let gradient = CAGradientLayer()

        gradient.frame = overlayView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0,0.5]
        overlayView.layer.mask = gradient
    }
    
    // MARK: - Navigation

    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        stopCurrentlyPlayingCell()
        
        performSegue(withIdentifier: "UnwindSetMelody", sender: self)
    }
    
    // MARK: - Actions
    
    /// Start or stop a preview of a melody
    @IBAction func playButtonPressed(_ sender: UIButton) {
        // Find the table cell for the melody we need to preview
        var view = sender.superview
        while view as? MelodyCell == nil {
            view = view!.superview
        }
        
        // A table cell for the melody we need to preview
        let selectedCell = view as! MelodyCell
        
        if (selectedCell.isPlaying) {
            pauseCurrentlyPlayingCell()
            return
        }
        
        play(cell: selectedCell)
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentlyPlayingCell()?.stop()
        indexOfCurrentlyPlayingCell = nil
    }
    
    // MARK: - Helper functions
    
    private func play(cell: MelodyCell) {
        // If the selected cell is currently playing we don't need to do anything
        if cell.isPlaying {
            return
        }
        
        // If the selected cell is paused, try resuming playback
        if cell.isPaused {
            if let success = audioPlayer?.play() {
                if success {
                    cell.play()
                    startUpdatingProgressBarFor(cell: cell)
                }
            }
            return
        }
        
        // If we got here, it means a user requested a new cell to play.
        // 1. If any other cell is playing, stop it.
        if indexOfCurrentlyPlayingCell != nil {
            stopCurrentlyPlayingCell()
        }
        
        // 2. Play the newly selected cell
        if let path = Bundle.main.path(forResource: cell.melodyName! + ".mp3", ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.setVolume(1.0, fadeDuration: 0.1)
                audioPlayer?.play()
                indexOfCurrentlyPlayingCell = melodiesTable.indexPath(for: cell)!.row
                cell.play()
                startUpdatingProgressBarFor(cell: cell)
            } catch {
                print("Playing a melody failed. \"\(cell.melodyName!).mp3\"")
                indexOfCurrentlyPlayingCell = nil
                cell.stop()
            }
            
        } else {
            print("Couldn't preview a melody because the sound file was not found: \"\(cell.melodyName!).mp3\"")
        }
    }
    
    /// Stops the audio and resets the variables so that they reflect the "nothing's playing" state
    private func stopCurrentlyPlayingCell() {
        currentlyPlayingCell()?.stop()
        indexOfCurrentlyPlayingCell = nil
        
        self.audioPlayer?.setVolume(0, fadeDuration: 0.05)
        Thread.sleep(forTimeInterval: 0.1)
        audioPlayer?.stop()
    }
    
    /// Pauses the audio if it is currently playing.
    private func pauseCurrentlyPlayingCell() {
        audioPlayer?.pause()
        currentlyPlayingCell()?.pause()
    }
    
    /// Gets the `MelodyCell` which is currently being previewed.
    ///
    /// - Returns: a `MelodyCell` that is being previewed or `nil` if no melody is being previewed.
    private func currentlyPlayingCell() -> MelodyCell? {
        if let i = indexOfCurrentlyPlayingCell {
            return melodiesTable.cellForRow(at: IndexPath(row: i, section: 0)) as? MelodyCell
        }
        return nil
    }
    
    private func startUpdatingProgressBarFor(cell: MelodyCell) {
        let queue = DispatchQueue(label: "PlaybackProgress", qos: .utility)
        queue.async {
            if let audioPlayer = self.audioPlayer {
                while audioPlayer.isPlaying && cell.isPlaying {
                    let progress = Float(audioPlayer.currentTime / audioPlayer.duration)
                    self.setProgress(progress, forCell: cell)

                    Thread.sleep(forTimeInterval: 0.25)
                }
            }
        }
    }
    
    private func setProgress(_ progress: Float, forCell cell: MelodyCell) {
        DispatchQueue.main.async {
            cell.setProgress(progress)
        }
    }
    
    private func selectRowFor(melody: String) {
        let indexOfSelectedMelody = melodies.firstIndex(of: melody)!
        melodiesTable.selectRow(at: IndexPath(row: indexOfSelectedMelody, section: 0),
                                animated: false,
                                scrollPosition: .none)
        self.tableView(melodiesTable, didSelectRowAt: IndexPath(row: indexOfSelectedMelody, section: 0))
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
    private(set) var isPlaying = false
    
    /// Indicates whether this melody is paused
    private(set) var isPaused = false
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var melodyNameLabel: UILabel!
    
    @IBOutlet weak var checkMarkLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    /// A name of the melody that is displayed in this cell
    var melodyName: String? {
        get {
            return melodyNameLabel.text
        }
    }
    
    /// Makes the cell enter the `Playing` state
    func play() {
        if isPlaying {
            return
        }
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        progressBar.isHidden = false
        isPlaying = true
        isPaused = false
        setNeedsDisplay()
    }
    
    /// Makes the cell enter the `Paused` state
    func pause() {
        if !isPlaying {
            return
        }
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        isPlaying = false
        isPaused = true
        setNeedsDisplay()
    }
    
    /// Makes  the cell enter the `Stopped` state
    func stop() {
        if !isPlaying && !isPaused {
            return
        }
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        progressBar.setProgress(0, animated: true)
        progressBar.isHidden = true
        isPlaying = false
        isPaused = false
        setNeedsDisplay()
    }
    
    /// Updates the progress bar
    func setProgress(_ progress: Float) {
        progressBar.setProgress(progress, animated: true)
    }
}

extension SetMelodyViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return melodies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as! MelodyCell
        
        cell.melodyNameLabel.text = melodies[indexPath.row]
        cell.isPicked = cell.melodyNameLabel.text == selectedMelody
        
        if indexPath.row == indexOfCurrentlyPlayingCell {
            if audioPlayer != nil && audioPlayer!.isPlaying {
                cell.play()
                startUpdatingProgressBarFor(cell: cell)
            } else {
                cell.pause()
            }
        } else {
            cell.stop()
        }
        
        return cell
    }
}

/// A delegate for the table that displays names of melodies
extension SetMelodyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MelodyCell {
            cell.isPicked = true
            selectedMelody = cell.melodyName
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MelodyCell {
            cell.isPicked = false
        }
    }
}
