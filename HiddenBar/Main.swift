//
//  main.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import AppKit

@main struct MyApp {
    
    static func main () -> Void {
        // Check for duplicated instances.
        let otherRunningInstances = NSWorkspace.shared.runningApplications.filter {
            $0.bundleIdentifier == Global.mainAppId && $0 != NSRunningApplication.current
        }
        let isAppAlreadyRunning = !otherRunningInstances.isEmpty
        
        if (isAppAlreadyRunning) {
            
            NSLog("Program already running: \(otherRunningInstances.map{$0.processIdentifier}).")
            return;
        }
        
        // Register user default
        Preferences.setDefault()
        
        // Load GUI
        NSLog("GUI started.")
        let ret_val = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
        NSLog("GUI exited with exit code: \(ret_val).")
        return
    }
}
