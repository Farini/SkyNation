//
//  GameViewController.swift
//  SkyNation iOS
//
//  Created by Carlos Farini on 12/18/20.
//

import UIKit
import SceneKit
import SwiftUI
import GameKit

class GameViewController: UIViewController {
    
    /// The Last SwiftUI opened View
    var openedView:UIView?

    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var gameController: GameController!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        self.gameController.gameNavDelegate = self
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = false
        
        // Configure the view
        self.gameView.backgroundColor = UIColor.black
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let screenSize = self.view.bounds.size
        let width = screenSize.width
        let height = screenSize.height
        
        print("\n iOS Screen Size")
        print("Width: \(width) Height: \(height)")
        
        // Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(closeView(_:)), name: .closeView, object: nil)
        
        print("Adding GameViewController as observer of the skedadddles")
        
        // Game Center Window management
        NotificationCenter.default.addObserver(self, selector: #selector(presentGameCenter(_:)), name: .openGameCenter, object: nil)
    }
    
    @objc func closeView(_ notification:Notification) {
        
        print("Should Close Notification Received")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
            self.openedView?.removeFromSuperview()
            self.openedView = nil
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Control
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        
        if openedView != nil {
            print("view is open")
            return
        } else {
            // Highlight the tapped nodes
            let p = gestureRecognizer.location(in: gameView)
            gameController.highlightNodes(atPoint: p)
            return
        }
        
    }
    
    func clearInterface() {
        if let opened = openedView {
            opened.removeFromSuperview()
            openedView = nil
        }
    }
    
    @objc func presentGameCenter(_ notification:Notification) {
        // GameCenter passes its own view controller.
        // present as sheet
        print("Presenting gamecenter")
        
        if let viewController:UIViewController = notification.object as? UIViewController {
            print("Notification has view controller")
            self.present(viewController, animated: true) {
                print("Game Center open")
            }
        } else {
            print("Notification has [ NO ] view controller")
        }
    }
}

// MARK: - Delegate

extension GameViewController:GameNavDelegate {
    
    func openCityView(posdex: Posdex, city: DBCity?) {
        
        clearInterface()
        
        let newHost = UIHostingController(rootView:MarsCityView(posdex: posdex))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func openOutpostView(posdex: Posdex, outpost: DBOutpost) {
        clearInterface()
        
        let newHost = UIHostingController(rootView:OutpostView(controller: OutpostController(dbOutpost: outpost)))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didChooseModule(name: String) {
        print("Module View")
        clearInterface()
        
        let newHost = UIHostingController(rootView:SelectModuleTypeView(name: name))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didSelectLab(module: LabModule) {
        print("Lab View")
        clearInterface()
        
        let newHost = UIHostingController(rootView: LaboratoryView(module: module))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didSelectHab(module: HabModule) {
        print("Hab View")
        clearInterface()
        let newHost = UIHostingController(rootView: HabModuleView(module: module))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didSelectBio(module: BioModule) {
        print("Bio View")
        clearInterface()
        let newHost = UIHostingController(rootView: BioView(bioMod: module))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didSelectTruss(station: Station) {
        print("Truss View")
        clearInterface()
        let newHost = UIHostingController(rootView: TrussLayoutView())
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didSelectGarage(station: Station) {
        print("Garage View")
        clearInterface()
        let newHost = UIHostingController(rootView: GarageView())
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    /// LSS Control
    func didSelectLSS(scene: GameSceneType) {
        switch scene {
            case .SpaceStation:
                
                let controller = UIHostingController(rootView: LSSView(scene: scene))
                
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(controller.view)
                controller.view.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor).isActive = true
                controller.view.centerYAnchor.constraint(
                    equalTo: view.centerYAnchor).isActive = true
                
                controller.didMove(toParent: self)
                self.openedView = controller.view
//                self.presentAsSheet(controller)
                
            case .MarsColony:
                
                let controller = UIHostingController(rootView: LSSView(scene: scene))
                
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(controller.view)
                controller.view.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor).isActive = true
                controller.view.centerYAnchor.constraint(
                    equalTo: view.centerYAnchor).isActive = true
                
                controller.didMove(toParent: self)
                self.openedView = controller.view
//                self.presentAsSheet(controller)
        }
    }
    
    func didSelectEarth() {
        print("Earth Order")
        clearInterface()
        let newHost = UIHostingController(rootView:EarthRequestView())
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
        
    }
    
    func didSelectSettings() {
        clearInterface()
        let newHost = UIHostingController(rootView: GameSettingsView(inGame: true))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didSelectMessages() {
        clearInterface()
        let newHost = UIHostingController(rootView: GuildRoom())
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func didSelectShopping() {
        clearInterface()
        let newHost = UIHostingController(rootView: GameShoppingView(controller: StoreController()))
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
    
    func openGameRoom() {
        clearInterface()
        
        let newHost = UIHostingController(rootView:GameRoomView())
        
        newHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHost.view)
        newHost.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        newHost.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        newHost.didMove(toParent: self)
        self.openedView = newHost.view
    }
}
