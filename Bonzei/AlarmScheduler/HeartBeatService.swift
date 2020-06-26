//
//  HeartBeatService.swift
//  Bonzei
//
//  Created by Tomasz on 10/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import AVFoundation
import os.log

class HeartBeatService {
    
    static let sharedInstance = HeartBeatService()
    
    private var audioPlayer: AVAudioPlayer?
    
    private var timer = Timer()
    
    private var log = OSLog(subsystem: "Alarm", category: "HeartBeatService")
    
    private init() {
        //register for notifications about interruptions
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(handleInterruption),
                         name: AVAudioSession.interruptionNotification,
                         object: nil)
        
        //Setup Audio Session
        setupAudioSession()
        
    }
    
    public func start() {
        
        if audioPlayer != nil {
            audioPlayer!.stop()
            audioPlayer = nil
        }
        
        let path = Bundle.main.path(forResource: "alarm.mp3", ofType: nil)!
            
        let url = URL(fileURLWithPath: path)
        
        setupAudioSession()
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            os_log("Activating the Heart Beat session failed", log: log, type: .error)
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer!.play()
            audioPlayer!.numberOfLoops = 10000
            audioPlayer!.volume = 0.0
        } catch {
            print("Starting the audio player failed")
        }
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target:self, selector: #selector(HeartBeatService.heartBeat),
        userInfo: nil, repeats: true)
        
        os_log("Heart Beat service started", log: log, type: .info)
    }
    
    public func stop() {
        if audioPlayer != nil {
            audioPlayer!.stop()
            audioPlayer = nil
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            os_log("Failed to deactivate the session: %s", log: log, type: .error, error.localizedDescription)
        }
        
        os_log("Heart Beat stopped", log: log, type: .info)
    }
    
    @objc func heartBeat() {
        //os_log("Heart Beat", log: log, type: .info)
        AlarmScheduler.sharedInstance.checkAndTriggerAlarms()
    }
    
    @objc func handleInterruption(notification: Notification) {
           guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        // Switch over the interruption type.
        switch type {

        case .began:
            logInfo("Heart Beat interruption began")
            
            if audioPlayer != nil {
                audioPlayer!.pause()
            }

        case .ended:
           logInfo("Heart Beat interruption ended")
           
           guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
           let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
           if options.contains(.shouldResume) {
                logInfo("Heart beat should resume")
                audioPlayer!.play()
            } else {
                logInfo("Heart Beat should not resume")
            }

        default: ()
            
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession
                .sharedInstance()
                .setCategory(.playback, mode: .default, options: [.mixWithOthers ])
        } catch {
            os_log("Failed to set up the audio session.", log: log, type: .error)
        }
    }
    
    private func logInfo(_ message: String) {
        os_log("%public{s}", log: OSLog.default, type: .info, message)
    }
    
    private func logError(_ message: String) {
        os_log("%public{s}", log: OSLog.default, type: .error, message)
    }
}
