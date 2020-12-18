//
//  AppDelegate.swift
//  SkyNation macOS
//
//  Created by Carlos Farini on 12/18/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let screen = NSScreen.main {
            let rect = screen.frame
            print("Screen frame: \(rect)")
            let height = rect.size.height
            let width = rect.size.width
            print("Screen width:\(width) x height:\(height)")
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

    @IBAction func openFinder(_ sender: NSMenuItem) {
        
        print("Getting finder")
        
        if let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Doc url: \(documentsPathURL)")
            // This gives you the URL of the path
            // print("Documents Path URL:\(documentsPathURL)")
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: documentsPathURL.absoluteString)
            //        }
        }else{
            print("Where is finder ??")
        }
    }
    
    @IBAction func openAppSupport(_ sender: NSMenuItem) {
        
        print("Getting finder")
        
        if let documentsPathURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            print("App Support url: \(documentsPathURL)")
            // This gives you the URL of the path
            // print("Documents Path URL:\(documentsPathURL)")
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: documentsPathURL.absoluteString)
            //        }
        }else{
            print("Where is finder ??")
        }
    }
    
}

