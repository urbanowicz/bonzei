//
//  RootViewViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class RootViewViewController: UITabBarController, AlarmSchedulerDelegate {
    
    private var dismissAlarmViewController: DismissAlarmViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AlarmScheduler.sharedInstance.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RootViewViewController.sceneDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        
        dismissAlarmViewController = nil
        
    }
    
    /// Called  after application has been launched or has moved to foreground
    @objc func sceneDidBecomeActive(notification: Notification) {
        if AlarmScheduler.sharedInstance.isAlarmPlaying && dismissAlarmViewController == nil {
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
        
        dismissAlarmVC.prepareToDismissAlarm(AlarmScheduler.sharedInstance.currentlyTriggeredAlarm)
        
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
}
