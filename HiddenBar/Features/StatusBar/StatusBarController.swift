//
//  StatusBarController.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import AppKit

enum StatusBarPolicy:Int {
    case  collapsed = 0, fullExpand = 1, partialExpand = 2
}

class StatusBarController {

    enum StatusBarValidity {
        case invalid; case onStartUp; case valid
    }
    
    private let masterToggle = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let primarySeprator = NSStatusBar.system.statusItem(withLength: 0)
    private let secondarySeprator = NSStatusBar.system.statusItem(withLength: 0)
    private let updateLock = NSLock()
    private var autoCollapseTimer: Timer? = nil
    
    private static let hiddenSepratorLength: CGFloat =  0
    private static let normalSepratorLength: CGFloat =  10
    private static var expandedSeperatorLength: CGFloat {
        let screenWidths = NSScreen.screens.map { $0.frame.width }

        if #available(macOS 27.0, *) {
            // macOS 27 discards a status item whose requested length reaches
            // half of a display's width. Staying just below that limit lets the
            // system move displaced items into its native overflow menu.
            let narrowestWidth = screenWidths.min() ?? 1728
            let widestWidth = screenWidths.max() ?? narrowestWidth

            // A status item has one length even though the menu bar is mirrored
            // across displays. With mixed display widths there is no value that
            // both hides on the narrowest display and leaves wider bars intact.
            // Default to normal-length, glyph-free separators so collapse is
            // effectively disabled without destabilizing item ordering; advanced
            // users can opt in to hiding on the narrowest display.
            if widestWidth > narrowestWidth && !Preferences.hideWithMixedDisplays {
                return normalSepratorLength
            }

            // On very wide displays, the distance that must be displaced is
            // already larger than macOS 27's per-item half-width limit. Avoid
            // shifting every icon when a full collapse is impossible.
            if narrowestWidth > 2_800 {
                return normalSepratorLength
            }

            return max(200, (narrowestWidth / 2 - 64).rounded(.down))
        }

        // macOS 26 and earlier clamp oversized items. Use the widest attached
        // display and retain the system's 10,000-point upper bound.
        let widestWidth = screenWidths.max() ?? 1728
        return max(500, min(widestWidth * 2, 10_000))
    }

    public static func areSeperatorPositionValid () -> StatusBarValidity {
        guard
            let toggleButtonX = instance.masterToggle.button?.getOrigin?.x,
            let primarySepratorX = instance.primarySeprator.button?.getOrigin?.x,
            let secondarySepratorX = instance.secondarySeprator.button?.getOrigin?.x
        else {return .invalid}
        
        // all x will be 0 if applicationDidFinishLaunching have not returned, so we have to try again
        if toggleButtonX == 0 && primarySepratorX == 0 && secondarySepratorX == 0 {return .onStartUp}
        
        if Global.isUsingLTRTypeSystem {
            return (toggleButtonX > primarySepratorX && primarySepratorX > secondarySepratorX) ? .valid : .invalid
        } else {
            return (toggleButtonX < primarySepratorX && primarySepratorX < secondarySepratorX) ? .valid : .invalid
        }
    }

    @objc private static func toggleButtonPressed(sender: NSStatusBarButton) {
        if let event = NSApp.currentEvent {
            
            let isOptionKeyPressed = event.modifierFlags.contains(NSEvent.ModifierFlags.option)
            let isControlKeyPressed = event.modifierFlags.contains(NSEvent.ModifierFlags.control)
            
            switch (event.type, isOptionKeyPressed, isControlKeyPressed) {
            case (NSEvent.EventType.leftMouseUp, false, false):
                if (Preferences.statusBarPolicy != .collapsed) {Preferences.statusBarPolicy  = .collapsed}
                else {Preferences.statusBarPolicy = .partialExpand}
                Preferences.isEditMode = false
            case (NSEvent.EventType.leftMouseUp, true, false):
                if (Preferences.statusBarPolicy != .collapsed) {Preferences.statusBarPolicy  = .collapsed}
                else {Preferences.statusBarPolicy = .fullExpand}
                Preferences.isEditMode = false
            case (NSEvent.EventType.rightMouseUp, _, _):
                fallthrough
            case (NSEvent.EventType.leftMouseUp, _, true):
                ContextMenuController.showContextMenu(sender)
            default:
                break
            }
        }
    }
    
    private static let instance = StatusBarController()
    private init() {
        if let button = masterToggle.button {
            button.image = Assets.collapseImage
            button.image?.isTemplate = true
            button.imageScaling = .scaleProportionallyDown
            button.toolTip = "Hidden Bar"
            button.setAccessibilityLabel("Hidden Bar")

            if button.image == nil {
                button.title = Global.isUsingLTRTypeSystem ? "‹" : "›"
                button.imagePosition = .noImage
            } else {
                button.imagePosition = .imageOnly
            }
        }

        if #available(macOS 27.0, *) {
            // A fixed allocation prevents the variable-length item from
            // collapsing to zero while AppKit restores managed status items.
            masterToggle.length = NSStatusItem.squareLength
        }
        
        if let button = primarySeprator.button {
            button.image = Assets.seperatorImage
        }
        
        if let button = secondarySeprator.button {
            button.image = Assets.seperatorImage
            button.appearsDisabled = true
        }
        masterToggle.autosaveName = "hiddenbar_masterToggle";
        primarySeprator.autosaveName = "hiddenbar_primarySeprator";
        secondarySeprator.autosaveName = "hiddenbar_secondarySeprator";
        NSLog("Status bar controller inited.")
    }
    
    public static func setup() {
        ContextMenuController.setup()
        
        let masterToggle = instance.masterToggle,
        primarySeprator = instance.primarySeprator,
        secondarySeprator = instance.secondarySeprator
        
        if let button = masterToggle.button {
            button.target = self
            button.action = #selector(toggleButtonPressed(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        // This won't work: blocking action to be sent.
        //let menu = StatusBarMenuManager.getContextMenu()
        //masterToggle.menu = menu
        
        masterToggle.isVisible = true
        primarySeprator.isVisible = true
        secondarySeprator.isVisible = true

        NotificationCenter.default.addObserver(forName: NotificationNames.prefsChanged, object: nil, queue: Global.mainQueue) {[] (notification) in
            triggerAdjustment()
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: Global.mainQueue
        ) { _ in
            // The safe macOS 27 separator length is display-dependent, so
            // re-apply the current state after a hot-plug/change. Repeat once
            // after AppKit has settled the mirrored status-item positions.
            triggerAdjustment()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                triggerAdjustment()
            }
        }
        
        // Manually adjusting the bar once
        triggerAdjustment()
    }
    
    private static func triggerAdjustment() {
        switch areSeperatorPositionValid() {
        case .onStartUp:
            Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: false) { _ in
                // retry on more time after 1s
                NotificationCenter.default.post(Notification(name: NotificationNames.prefsChanged, object: Preferences.isAutoStart))
            }
            fallthrough
        case .valid:
            resetAutoCollapseTimer()
            adjustStatusBar()
            adjustMenuBar()
        case .invalid:
            resetSeperator()
        }
    }
    
    private static func resetSeperator () {
        let masterToggle = instance.masterToggle,
            primarySeprator = instance.primarySeprator,
            secondarySeprator = instance.secondarySeprator,
            lock = instance.updateLock
        lock.lock(before: Date(timeIntervalSinceNow: 1))
        primarySeprator.length = StatusBarController.normalSepratorLength
        secondarySeprator.length = StatusBarController.normalSepratorLength
        setSeparatorGlyphsVisible(primary: true, secondary: true)
        masterToggle.button?.image = Assets.expandImage
        masterToggle.button?.title = "Invalid".localized
        lock.unlock()
    }
    
    private static func resetAutoCollapseTimer () {
        let lock = instance.updateLock
        do {
            lock.lock(before: Date(timeIntervalSinceNow: 1))
            defer {lock.unlock()}
            //NSLog("Timer Cancelled:\(String(describing: instance.autoCollapseTimer)).")
            instance.autoCollapseTimer?.invalidate()
            switch (Preferences.isAutoHide, Preferences.isEditMode, Preferences.statusBarPolicy) {
            case (false, _, _), (_, true, _), (_, _, .collapsed):
                return
            default:
                break
            }
            let timer = Timer(timeInterval: TimeInterval(Preferences.numberOfSecondForAutoHide), repeats: false) {
                [] (timer:Timer) in
                //NSLog("Timer Triggered:\(timer).")
                Preferences.statusBarPolicy = .collapsed
                return
            }
            //NSLog("Timer Dispatched:\(timer).")
            Global.runLoop.add(timer, forMode: .common)
            instance.autoCollapseTimer = timer
        }
    }
    
    private static func adjustStatusBar () {
        let masterToggle = instance.masterToggle,
            primarySeprator = instance.primarySeprator,
            secondarySeprator = instance.secondarySeprator,
            lock = instance.updateLock
        
        lock.lock(before: Date(timeIntervalSinceNow: 1))
        let expandedLength = StatusBarController.expandedSeperatorLength
        if Preferences.isEditMode {
            primarySeprator.length = StatusBarController.normalSepratorLength
            //primarySeprator.isVisible = true
            secondarySeprator.length = StatusBarController.normalSepratorLength
            //secondarySeprator.isVisible = true
            masterToggle.button?.image = Assets.expandImage
            masterToggle.button?.title = "Edit".localized
            setSeparatorGlyphsVisible(primary: true, secondary: true)
            
        }
        else {
            switch Preferences.statusBarPolicy {
            case .fullExpand:
                primarySeprator.length = StatusBarController.hiddenSepratorLength
                //primarySeprator.isVisible = false
                secondarySeprator.length = StatusBarController.hiddenSepratorLength
                //secondarySeprator.isVisible = false
                masterToggle.button?.image = Assets.expandImage
                masterToggle.button?.title = ""
                setSeparatorGlyphsVisible(primary: true, secondary: true)
                
            case .partialExpand:
                primarySeprator.length = StatusBarController.hiddenSepratorLength
                //primarySeprator.isVisible = false
                secondarySeprator.length = expandedLength
                //secondarySeprator.isVisible = true
                masterToggle.button?.image = Assets.expandImage
                masterToggle.button?.title = ""
                setSeparatorGlyphsVisible(primary: true, secondary: false)
                
            case .collapsed:
                primarySeprator.length = expandedLength
                //primarySeprator.isVisible = true
                secondarySeprator.length = expandedLength
                //secondarySeprator.isVisible = true
                masterToggle.button?.image = Assets.collapseImage
                masterToggle.button?.title = ""
                setSeparatorGlyphsVisible(primary: false, secondary: false)
                
            }
        }
        lock.unlock()
    }

    private static func setSeparatorGlyphsVisible(primary: Bool, secondary: Bool) {
        guard #available(macOS 27.0, *) else { return }
        instance.primarySeprator.button?.image = primary ? Assets.seperatorImage : nil
        instance.secondarySeprator.button?.image = secondary ? Assets.seperatorImage : nil
    }

    private static func adjustMenuBar () {
        if #available(macOS 27.0, *) {
            // Status items can be hidden by the system or because the menu bar
            // has insufficient space. A regular activation policy keeps the
            // Preferences window reachable from the Dock in either case.
            NSApp.setActivationPolicy(.regular)
            return
        }
        
        //TODO: do not deactivate if preference window is shown
        let lock = instance.updateLock
        
        lock.lock(before: Date(timeIntervalSinceNow: 1))
        if !Preferences.isUsingFullStatusBar {
            NSApp.setActivationPolicy(.accessory)
        }
        else {
            let shouldActiveIgnoringOtherApp = !Util.hasFullScreenWindow()
            switch (Preferences.isEditMode, Preferences.statusBarPolicy) {
                
            case (true, _), (_, .partialExpand), (_, .fullExpand):
                if Preferences.isUsingFullStatusBar {
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: shouldActiveIgnoringOtherApp)
                }
            case (false, .collapsed):
                NSApp.setActivationPolicy(.accessory)
                NSApp.deactivate()
            }
        }
        lock.unlock()
    }
}
