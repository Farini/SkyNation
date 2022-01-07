//
//  StartingViewController.swift
//  SkyNation iOS
//
//  Created by Carlos Farini on 1/26/21.
//

import UIKit
import SwiftUI

class StartingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addStartingView()
        // Add Notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(startGame(_:)), name: .startGame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentGameCenter(_:)), name: .openGameCenter, object: nil)
    }
    
    /// Add the First (Intro) View
    func addStartingView() {
        let startView = GameSettingsView()
        let controller = UIHostingController(rootView: startView)
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            controller.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0),
            controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    /// Notification for game to Start (perform segue)
    @objc func startGame(_ notification:Notification) {
        // Remove Observer
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "startgame", sender: self)
    }
    
    // MARK: - Game Center
    
    // Presentation from GameCenter should be re-routed
    var gvc:GameViewController?
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let vc = viewControllerToPresent as? GameViewController {
            self.gvc = vc
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            // GameViewController is up, make that one present
            if let gvc = gvc {
                gvc.presentGameCenter(Notification(name: .openGameCenter, object: viewControllerToPresent, userInfo: nil))
            } else {
                super.present(viewControllerToPresent, animated: flag, completion: completion)
            }
        }
    }
    
    /// Present game center to Login
    @objc func presentGameCenter(_ notification:Notification) {
        // GameCenter passes its own view controller.
        // present as sheet
        print("Attempting to present GameCenter in Starting VC")
        
        if let viewController:UIViewController = notification.object as? UIViewController {
            self.present(viewController, animated: true) {
                print("Game Center open")
            }
        }
    }
    
    // MARK: - View Settings
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension StartingViewController {
    
}
