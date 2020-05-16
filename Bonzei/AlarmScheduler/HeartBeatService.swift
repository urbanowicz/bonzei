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
        
        let path = Bundle.main.path(forResource: "Forest Light Rays.mp3", ofType: nil)!
            
        let url = URL(fileURLWithPath: path)
        
        setupAudioSession()
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print ("Activating a session failed")
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
    }
    
    @objc func heartBeat() {
        os_log("Heart Beat", log: OSLog.default, type: .info)
        AlarmScheduler.sharedInstance.checkAndRunAlarms()
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
            print ("interruption began")
            if audioPlayer != nil {
                audioPlayer!.pause()
            }

        case .ended:
           print("interruption ended")
           
           guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
           let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
           if options.contains(.shouldResume) {
                print("audio should resume")
                audioPlayer!.play()
            } else {
                print("audio should not resume")
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
            print("Failed to set audio session category.")
        }
    }
}
