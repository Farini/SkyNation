//
//  AppDelegate.swift
//  SkyNation macOS
//
//  Created by Carlos Farini on 12/18/20.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("App finished launch")
        if let screen = NSScreen.main {
            let rect = screen.frame
            print("Screen frame: \(rect)")
            let height = rect.size.height
            let width = rect.size.width
            print("Screen width:\(width) x height:\(height)")
        }
        
        // Check Database
        if let player = LocalDatabase.shared.player {
            print("There is a player \(player.name)")
        } else {
            print("No Player")
            let window = ClosableWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("SUI Window")
            window.contentView = NSHostingView(rootView: GameSettingsView())
            window.makeKeyAndOrderFront(nil)
        }
        
        
        // Maximize the window
        //        if let screen = NSScreen.mainScreen() {
        //            window.setFrame(screen.visibleFrame, display: true, animate: true)
        //        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}


class MacMenu:NSObject, NSMenuDelegate {
    
    @IBAction func openFinder(_ sender: NSMenuItem) {
        
        print("Getting finder (From MACMENU)")
        
        if let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("opening workspace")
            NSWorkspace.shared.activateFileViewerSelecting([dataPath])
        }
    }
    
    @IBAction func openAppSupport(_ sender: NSMenuItem) {
        
        print("Getting finder")
        
        if let dataPath = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first {
            
            NSWorkspace.shared.activateFileViewerSelecting([dataPath])
        }
    }
}

