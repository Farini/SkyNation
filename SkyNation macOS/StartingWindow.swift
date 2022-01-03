//
//  StartingWindow.swift
//  SkyNation macOS
//
//  Created by Carlos Farini on 1/25/21.
//

import Cocoa
import SwiftUI

class StartingWindow: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        self.window!.center()
        self.window!.setFrameAutosaveName("SUI Window")
        self.window!.contentView = NSHostingView(rootView: GameSettingsView())
        self.window!.makeKeyAndOrderFront(nil)
        window?.title = "SkyNation"
        window?.delegate = self
        
        // Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(startGame(_:)), name: .startGame, object: nil)
        
        // Game Center
        NotificationCenter.default.addObserver(self, selector: #selector(presentGameCenter(_:)), name: .openGameCenter, object: nil)
    }
    
    @objc func startGame(_ notification:Notification) {
        
        let stb = NSStoryboard(name: "Main", bundle: Bundle.main)
        if let newWindowController = stb.instantiateInitialController() as? NSWindowController {
            
            if let newWindow = newWindowController.window {
                print("New Window here: \(newWindow.title)")
                newWindow.makeKeyAndOrderFront(self)
                
                // Close this window
                self.window?.close()
                
                // Delegate this window as well.
                newWindow.delegate = self
            }
        }
    }
    
    
    @objc func presentGameCenter(_ notification:Notification) {
        // GameCenter passes its own view controller.
        // present as sheet
        if let viewController:NSViewController = notification.object as? NSViewController {
            self.window?.contentViewController?.presentAsSheet(viewController)
        }
    }
    
    /*
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            window.isReleasedWhenClosed = true
            print("A Window from window call \(window.title)")
        } else {
            print("Another Window will close: \(window?.title ?? "n/a")")
        }
        
    }
    */
    
}
