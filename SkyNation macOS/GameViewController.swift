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

class GameViewController: NSViewController, GameNavDelegate, NSWindowDelegate {
    
    @IBOutlet weak var sceneKitView: SCNView!
    
    var gameView: SCNView {
        return sceneKitView
    }
    
    var gameController: GameController!
    
    // MARK: - Window Delegate
    
    //    func windowDidBecomeKey(_ notification: Notification) {
    //            window?.level = .statusBar
    //        }
    
//    func windowWillClose(_ notification: Notification) {
//        NSApp.stopModal()
//    }
    
//    var gameView: SCNView {
//        return self.view as! SCNView
//    }
    
//    var gameController: GameController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        self.gameController.gameNavDelegate = self
        
        // Configure the view
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = true
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers:[NSGestureRecognizer] = gameView.gestureRecognizers
        gestureRecognizers.append(clickGesture)
        self.gameView.gestureRecognizers = gestureRecognizers
        
    }
    
    // MARK: - Control
    
    @objc func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // Highlight the clicked nodes
        let p = gestureRecognizer.location(in: gameView)
        gameController.highlightNodes(atPoint: p)
    }
    
    // MARK: - Delegate - GameNavDelegate
    
    func didSelectEarth() {
        
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("SUI Window")
        window.minSize = NSSize(width: 600, height: 400)
        
        let hostess = NSHostingView(rootView: EarthRequestView())
        window.contentView = hostess
        window.makeKeyAndOrderFront(nil)
    }
    
    func didSelectGarage(station: Station) {
        print("Garage selected")
        
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("SUI Window")
        window.contentView = NSHostingView(rootView: GarageView())
        window.makeKeyAndOrderFront(nil)
        
    }
    
    func didSelectAir() {
        print("Create Hab Module View to View This")
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("SUI Window")
        window.contentView = NSHostingView(rootView: LifeSupportView())
        window.makeKeyAndOrderFront(nil)
    }
    
    func didSelectHab(module: HabModule) {
        print("Create Hab Module View to View This")
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("SUI Window")
        window.contentView = NSHostingView(rootView: HabModuleView(module: module))
        window.makeKeyAndOrderFront(nil)
    }
    
    func didSelectBio(module: BioModule) {
        print("Create Bio Module View to see this")
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("SUI Window")
        window.contentView = NSHostingView(rootView: BioView(bioMod: module))
        window.makeKeyAndOrderFront(nil)
    }
    
    func didChooseModule(name: String) {
        
        let window = ClosableWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                                    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                                    backing: .buffered, defer: false)
        
        // Present view
        window.center()
        window.setFrameAutosaveName("SUI Window")
        window.contentView = NSHostingView(rootView: SelectModuleTypeView(name: name))
        window.makeKeyAndOrderFront(nil)
        
    }
    
    func didSelectLab(module: LabModule) {
        print("Selected lab. Capacity: \(module.capacity)")
        
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: LaboratoryView(module: module))
        window.makeKeyAndOrderFront(nil)
    }
    
    func didSelectTruss(station:Station) {
        print("Selected Truss")
        let window = ClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: LifeSupportView())
        window.makeKeyAndOrderFront(nil)
    }
    
    // menu
    
//    @IBAction func openfinder(_ sender: NSMenuItem) {
//        print("Can we open now ???")
//        
//    }
    
}

class ClosableWindow:NSWindow {
    
    override func close() {
        self.orderOut(NSApp)
    }
    
}
