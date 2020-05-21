//
//  RootViewViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class RootViewViewController: UITabBarController, AlarmSchedulerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AlarmScheduler.sharedInstance.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RootViewViewController.sceneDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /// Called  after application has been launched or has moved to foreground
    @objc func sceneDidBecomeActive(notification: Notification) {
        if AlarmScheduler.sharedInstance.isAlarmPlaying {
            presentDismissAlarmViewController()
        }
    }
    
    // MARK: - AlarmSchedulerDelegate
    
    /// Called by the AlarmScheduler when an alarm has been triggerred.
    func didTriggerAlarm(_ alarm: Alarm) {
        // if the app is open and alarm has been triggered present `DismissAlarmViewController`
        let state = UIApplication.shared.applicationState
        
        if self.isViewLoaded && state == .active {
            presentDismissAlarmViewController()
        }
    }
    
    private func presentDismissAlarmViewController() {
        guard let currentVC = getCurrentlyPresentedViewController() else { return }
        
        let dismissAlarmVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "DismissAlarmViewController") as! DismissAlarmViewController
        
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
