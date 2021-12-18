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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addStartingView()
        // Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(startGame(_:)), name: .startGame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentGameCenter(_:)), name: .openGameCenter, object: nil)
    }
    
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
    
    @objc func startGame(_ notification:Notification) {
        self.performSegue(withIdentifier: "startgame", sender: self)
    }
    
    @objc func presentGameCenter(_ notification:Notification) {
        // GameCenter passes its own view controller.
        // present as sheet
        if let viewController:UIViewController = notification.object as? UIViewController {
            self.present(viewController, animated: true) {
                print("Game Center open")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
