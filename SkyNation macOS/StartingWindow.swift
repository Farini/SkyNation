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
        self.window!.contentView = NSHostingView(rootView: GameSettingsView(guildController: GuildController(autologin: true)))
        self.window!.makeKeyAndOrderFront(nil)
        window?.title = "SkyNation"
        
        // Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(startGame(_:)), name: .startGame, object: nil)
        
    }
    
    @objc func startGame(_ notification:Notification) {
        
        let stb = NSStoryboard(name: "Main", bundle: Bundle.main)
        if let newWindowController = stb.instantiateInitialController() as? NSWindowController {
            
            if let newWindow = newWindowController.window {
                print("New Window here: \(newWindow.title)")
                newWindow.makeKeyAndOrderFront(self)
                
                // Close this window
                self.window?.close()
            }
        }
    }
    
}
