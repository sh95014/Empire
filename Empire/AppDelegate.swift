//
//  AppDelegate.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    var gameWindowController: GameWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let game = Game()
        
        gameWindowController = GameWindowController(game)
        gameWindowController?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

