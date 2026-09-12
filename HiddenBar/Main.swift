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
        // Prevent launching the same app bundle twice, while allowing a newer
        // copy from another location to replace or diagnose an installed copy.
        let currentBundleURL = Bundle.main.bundleURL.resolvingSymlinksInPath()
        let otherRunningInstances = NSWorkspace.shared.runningApplications.filter {
            guard
                $0.bundleIdentifier == Global.mainAppId,
                $0 != NSRunningApplication.current,
                let bundleURL = $0.bundleURL?.resolvingSymlinksInPath()
            else { return false }

            return bundleURL == currentBundleURL
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
