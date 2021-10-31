//
//  GameViewController.swift
//  SkyNation macOS
//
//  Created by Carlos Farini on 12/18/20.
//

import Cocoa
import SceneKit
import SpriteKit
import SwiftUI

class GameViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var sceneKitView: SCNView!
    
    /// The main View of the game
    var gameView: SCNView {
        return sceneKitView
    }
    
    /// The Game Controller
    var gameController: GameController!
    
    /// Presented View (if any)
    var openedView:NSView?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        self.gameController.gameNavDelegate = self
        
        // Configure the view
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers:[NSGestureRecognizer] = gameView.gestureRecognizers
        gestureRecognizers.append(clickGesture)
        self.gameView.gestureRecognizers = gestureRecognizers
        
    }
    
    override func viewDidAppear() {
        // Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(closeView(_:)), name: .closeView, object: nil)
    }
    
    /// Close the currently presented  `View`
    @objc func closeView(_ notification:Notification) {
        print("Closing current view")
        if let sheet = self.presentedViewControllers?.first {
            print("Dismissing Sheet")
            dismiss(sheet)
        }
        openedView = nil
    }
    
    // MARK: - Control
    
    @objc func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // Highlight the clicked nodes
        let p = gestureRecognizer.location(in: gameView)
        gameController.highlightNodes(atPoint: p)
    }
    
}

// MARK: - Delegate - GameNavDelegate

#if os(macOS)
extension GameViewController: GameNavDelegate {
    
    
    
    func didSelectEarth() {
        
        let controller = NSHostingController(rootView: EarthRequestView()) //UIHostingController(rootView:EarthRequestView())
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
        
    }
    
    func didSelectGarage(station: Station) {
        
        let controller = NSHostingController(rootView: GarageView()) //UIHostingController(rootView:EarthRequestView())
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
    }
    
    /// LSS Control
    func didSelectLSS(scene: GameSceneType) {
        switch scene {
            case .SpaceStation:
                
                let controller = NSHostingController(rootView: LSSView(scene: scene))
                
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(controller.view)
                controller.view.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor).isActive = true
                controller.view.centerYAnchor.constraint(
                    equalTo: view.centerYAnchor).isActive = true
                
                self.openedView = controller.view
                self.presentAsSheet(controller)
            
            case .MarsColony:
                
                let controller = NSHostingController(rootView: LSSView(scene: scene))
                
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(controller.view)
                controller.view.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor).isActive = true
                controller.view.centerYAnchor.constraint(
                    equalTo: view.centerYAnchor).isActive = true
                
                self.openedView = controller.view
                self.presentAsSheet(controller)
        }
    }
    
    func didSelectHab(module: HabModule) {
        //        print("Create Hab Module View to View This")
        
        let controller = NSHostingController(rootView: HabModuleView(module: module)) //UIHostingController(rootView:EarthRequestView())
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
        
        /*
         let window = ClosableWindow(
         contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
         styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
         backing: .buffered, defer: false)
         window.center()
         window.setFrameAutosaveName("SUI Window")
         window.contentView = NSHostingView(rootView: HabModuleView(module: module))
         window.makeKeyAndOrderFront(nil)
         */
        
    }
    
    func didSelectBio(module: BioModule) {
        //        print("Create Bio Module View to see this")
        
        let controller = NSHostingController(rootView: BioView(bioMod: module)) //UIHostingController(rootView:EarthRequestView())
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
        
        /*
         let window = ClosableWindow(
         contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
         styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
         backing: .buffered, defer: false)
         window.center()
         window.setFrameAutosaveName("SUI Window")
         window.contentView = NSHostingView(rootView: BioView(bioMod: module))
         window.makeKeyAndOrderFront(nil)
         */
    }
    
    func didChooseModule(name: String) {
        
        let controller = NSHostingController(rootView: SelectModuleTypeView(name: name)) //UIHostingController(rootView:EarthRequestView())
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
        
        /*
         let window = ClosableWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
         styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
         backing: .buffered, defer: false)
         
         // Present view
         window.center()
         window.setFrameAutosaveName("SUI Window")
         window.contentView = NSHostingView(rootView: SelectModuleTypeView(name: name))
         window.makeKeyAndOrderFront(nil)
         */
    }
    
    func didSelectLab(module: LabModule) {
        
        let controller = NSHostingController(rootView: LaboratoryView(module: module)) //UIHostingController(rootView:EarthRequestView())
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
        
        /*
         let window = ClosableWindow(
         contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
         styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
         backing: .buffered, defer: false)
         window.center()
         window.contentView = NSHostingView(rootView: LaboratoryView(module: module))
         window.makeKeyAndOrderFront(nil)
         */
    }
    
    func didSelectTruss(station:Station) {
        
        let controller = NSHostingController(rootView: TrussLayoutView()) //UIHostingController(rootView:EarthRequestView())
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
        
    }
    
    func didSelectSettings() {
        
        let controller = NSHostingController(rootView: GameSettingsView(inGame:true))
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
    }
    
    func didSelectMessages() {
        let controller = NSHostingController(rootView: ChatBubbleView())
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
    }
    
    func didSelectShopping() {
        
        let controller = NSHostingController(rootView: GameShoppingView(controller: StoreController()))
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
    }
    
    // MARS
    
    //func openCityView(position: Vector3D, name: String?) {
    func openCityView(posdex: Posdex, city: DBCity?) {
       
//        print("Should open city view at (x): \(position.x)")
        
        let controller = NSHostingController(rootView: MarsCityView(posdex: posdex)) //MarsCityCreatorView(posdex: posdex)) //MarsCityCreatorView(name: name ?? "", position: position))
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
    }
    
    func openOutpostView(posdex: Posdex, outpost:DBOutpost) {
        
        let controller = NSHostingController(rootView: OutpostView(controller: OutpostController(dbOutpost: outpost)))
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        controller.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        self.openedView = controller.view
        self.presentAsSheet(controller)
    }
    
}
#endif

// Deprecate
class ClosableWindow:NSWindow {
    
    override func close() {
        self.orderOut(NSApp)
    }
    
}
