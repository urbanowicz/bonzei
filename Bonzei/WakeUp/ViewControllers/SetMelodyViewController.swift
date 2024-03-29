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
    
    /// A semi transparent view that covers the top of the melodies table
    @IBOutlet weak var overlayTopView: UIView!
    
    /// A semi transparent view that covers the bottom of the melodies table
    @IBOutlet weak var overlayView: UIView!
    
    let melodyCellReuseId = "MelodiesTableCell"
    
    let shuffleCellReuseId = "ShuffleCell"
    
    let fadeInDuration: TimeInterval = 2.0
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.backgroundColor = UIColor.clear
        
        overlayTopView.isUserInteractionEnabled = false
        overlayView.isUserInteractionEnabled = false
        
        melodiesTable.dataSource = self
        melodiesTable.delegate = self
        
        melodiesTable.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidLayoutSubviews() {
        if isBeingPresented {
            selectRowFor(melody: selectedMelody!)
        }
        
        // top overlay
        let topOverlayMask = CAGradientLayer()
        topOverlayMask.frame = overlayTopView.bounds
        topOverlayMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        topOverlayMask.locations = [0.5, 1.0]
        overlayTopView.layer.mask = topOverlayMask
        
        // bottom overlay
        let gradient = CAGradientLayer()

        gradient.frame = overlayView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 0.5]
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
                //audioPlayer?.setVolume(0, fadeDuration: 0)
                //audioPlayer?.setVolume(1.0, fadeDuration: fadeInDuration)
                
                let startTime = melodyStartTime[cell.melodyName!] ?? 0
                audioPlayer?.currentTime = startTime
                
                if startTime > 0 {
                    audioPlayer?.setVolume(0, fadeDuration: 0)
                } else {
                    audioPlayer?.setVolume(1.0, fadeDuration: 0)
                }
                
                audioPlayer?.play()
                
                if startTime > 0 {
                    audioPlayer?.setVolume(1.0, fadeDuration: fadeInDuration * 10)
                }
                
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
        var indexOfSelectedMelody = 0
        if melody == "Shuffle" {
            indexOfSelectedMelody = melodies.count
        } else {
            indexOfSelectedMelody = melodies.firstIndex(of: melody)!
        }
        melodiesTable.selectRow(at: IndexPath(row: indexOfSelectedMelody, section: 0),
                                animated: false,
                                scrollPosition: .none)
        self.tableView(melodiesTable, didSelectRowAt: IndexPath(row: indexOfSelectedMelody, section: 0))
    }
}

//MARK:- UITableViewDataSource
extension SetMelodyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return melodies.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == melodies.count  {
            let cell = tableView.dequeueReusableCell(withIdentifier: shuffleCellReuseId) as! ShuffleCell
            cell.isPicked = selectedMelody == "Shuffle"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: melodyCellReuseId) as! MelodyCell
        
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

//MARK: - UITableViewDelegate
/// A delegate for the table that displays names of melodies
extension SetMelodyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: indexPath) as? MelodiesTableCell {
            cell.select()
            selectedMelody = cell.getMelodyName()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MelodiesTableCell {
            cell.deselect()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == melodies.count {
            return ShuffleCell.rowHeight
        } else {
            return MelodyCell.rowHeight
        }
    }
}

private protocol MelodiesTableCell {
    func select()
    func deselect()
    func getMelodyName() -> String?
}


//MARK:- MelodyCell
/// A custom `UITableViewCell` for the `melodiesTable`
class MelodyCell: UITableViewCell, MelodiesTableCell {
    
    public static let rowHeight: CGFloat = 75.0
    
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
    
    func select() {
        isPicked = true
    }
    
    func deselect() {
        isPicked = false
    }
    
    func getMelodyName() -> String? {
        return melodyName
    }
    
    /// Makes the cell enter the `Playing` state
    func play() {
        if isPlaying {
            return
        }
        playButton.setImage(UIImage(named: "pause-button-regular"), for: .normal)
        //progressBar.isHidden = false
        isPlaying = true
        isPaused = false
        setNeedsDisplay()
    }
    
    /// Makes the cell enter the `Paused` state
    func pause() {
        if !isPlaying {
            return
        }
        playButton.setImage(UIImage(named: "play-button-regular"), for: .normal)
        isPlaying = false
        isPaused = true
        setNeedsDisplay()
    }
    
    /// Makes  the cell enter the `Stopped` state
    func stop() {
        if !isPlaying && !isPaused {
            return
        }
        playButton.setImage(UIImage(named: "play-button-regular"), for: .normal)
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

//MARK:- ShuffleCell

class ShuffleCell: UITableViewCell, MelodiesTableCell {
    
    public static let rowHeight: CGFloat = 120.0
    
    @IBOutlet weak var checkMarkLabel: UILabel!
    
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
    
    func select() {
        isPicked = true
    }
    
    func deselect() {
        isPicked = false
    }
    
    func getMelodyName() -> String? {
        return "Shuffle"
    }
}
