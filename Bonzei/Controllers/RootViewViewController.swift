//
//  RootViewViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import MediaPlayer

class RootViewViewController: UITabBarController, AlarmSchedulerDelegate {
    
    private var dismissAlarmViewController: DismissAlarmViewController?

    private var volumeView: MPVolumeView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AlarmScheduler.sharedInstance.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RootViewViewController.sceneDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        
        dismissAlarmViewController = nil
        
        volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        volumeView.isHidden = true
        view.addSubview(volumeView)
    }
    
    /// Called  after application has been launched or has moved to foreground
    @objc func sceneDidBecomeActive(notification: Notification) {
        let scheduler = AlarmScheduler.sharedInstance
        if (scheduler.isAlarmPlaying || scheduler.isAlarmSnoozed) && dismissAlarmViewController == nil {
            presentDismissAlarmViewController()
        }
    }
    
    // MARK: - AlarmSchedulerDelegate
    
    func didTriggerAlarm(_ alarm: Alarm) {
        // if the app is open and alarm has been triggered present `DismissAlarmViewController`
        let state = UIApplication.shared.applicationState
        
        if self.isViewLoaded && state == .active && dismissAlarmViewController == nil {
            presentDismissAlarmViewController()
        } else if dismissAlarmViewController != nil {
            dismissAlarmViewController!.didTriggerAlarm(alarm)
        }
        
        turnSystemVolumeUp()
    }
    
    func didSnoozeAlarm(_ alarm: Alarm) {
        if let dismissAlarmViewController = self.dismissAlarmViewController {
            dismissAlarmViewController.didSnoozeAlarm(alarm)
        }
    }
    
    func didDismissAlarm(_ alarm: Alarm) {
        dismissAlarmViewController = nil
    }
    
    private func presentDismissAlarmViewController() {
        guard let currentVC = getCurrentlyPresentedViewController() else { return }
        
        let dismissAlarmVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "DismissAlarmViewController") as! DismissAlarmViewController
        
        self.dismissAlarmViewController = dismissAlarmVC
        
        dismissAlarmVC.modalPresentationStyle = .overFullScreen
        
        dismissAlarmVC.prepareToDismissAlarm()
        
        currentVC.present(dismissAlarmVC, animated: true, completion: nil)
    }
    
    private func getCurrentlyPresentedViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        guard var currentViewController = keyWindow?.rootViewController else { return nil }
        
        while let presentedViewController = currentViewController.presentedViewController {
            currentViewController = presentedViewController
        }
        
        return currentViewController
    }
    
    private func turnSystemVolumeUp() {
        let slider = volumeView.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider
        
        if slider != nil {
            if slider!.value < 0.6 {
                slider!.setValue(0.6, animated: false)
            }
        }
    }
}
