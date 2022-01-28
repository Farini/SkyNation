//
//  GameWindowController.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/27/22.
//

import Cocoa

/**
 This is the Window where the game is presented.
 
 To fix the `closingWindow` problem, this delegate was created. It wont be used with the rest of the code.
 
 This delegate controls events that manipulate the window.
 Its purpose is to manage when this window is being minimized vs being closed vs being resized.
 
 Finally, if there is any other action to be performed when `zooming` the window completely (full screen, or maximized)
 this class can offer solutions for that as well.
 
 - seealso: NSWindowDelegate
 */
class GameWindowController: NSWindowController {
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        print("\n\n --------- Window did load")
        self.window!.center()
        self.window!.setFrameAutosaveName("Game Window")
        self.window!.delegate = self
        
    }
    
}

extension GameWindowController:NSWindowDelegate {
    
    func windowDidBecomeKey(_ notification: Notification) {
        print("\n *** BECAME KEY ***")
    }
    
    // MARK: - Window Delegate
    
    func windowWillMiniaturize(_ notification: Notification) {
        print("Miniaturizing Window")
    }
    
    func windowDidMiniaturize(_ notification: Notification) {
        print("did miniature")
    }
    
    func windowDidDeminiaturize(_ notification: Notification) {
        print("Coming back up")
    }
    
    // Full Screen
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        // The window has entered full-screen mode.
        print("fullscreen")
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        // The window has left full-screen mode.
        print("fullscreen")
    }
    
    // Closing
    
    func windowWillClose(_ notification: Notification) {
        
        print("Closing this window will terminate the app.")
        print("1. Save game progress")
        print("2. Post GameCenter scores + achievements")
        
        
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if sender == self.window {
            return true
        } else {
            print("This window doesn't belong to this delegate.")
            return false
        }
    }
}
