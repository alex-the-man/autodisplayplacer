//
//  AppDelegate.swift
//  autodisplayplacer
//
//  Created by Alex Man on 1/5/21.
//

import Cocoa

// These are used in Storyboard bindings. Do not change.
struct ConfigKeys {
    static let executeCmdOnStart = "executeCmdOnStart"
    static let cmd = "cmd"
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusBarMenu: NSMenu?
    
    let displayChangeQueue = DispatchQueue(label: "DisplayChangeQueue")
    let userDefaults: UserDefaults
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    
    lazy var preferencesViewController = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "preferencesID")) as! NSWindowController
    
    var prevDisplayCount: UInt32 = getDisplayCount()
    var statusItem: NSStatusItem?
    
    override init() {
        NSUserDefaultsController.shared.appliesImmediately = false

        userDefaults = UserDefaults.standard
        userDefaults.register(
            defaults: [
                ConfigKeys.executeCmdOnStart: true,
                ConfigKeys.cmd: "say \"Screen change detected\"",
            ]
        )
    }
    
    func applicationDidFinishLaunching(_ aNotification:  Notification) {
        createStatusBarIcon()
        
        NSLog("Initial display count: %d", prevDisplayCount)
        if userDefaults.bool(forKey: ConfigKeys.executeCmdOnStart) {
            self.executeConfiguredCmd(force: true)
        }
    }
    
    func createStatusBarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        let statusBarIconImage = NSImage(named: "StatusBarIcon")!
        statusItem!.button?.image = statusBarIconImage
        statusItem!.menu = statusBarMenu
    }
    
    func applicationDidChangeScreenParameters(_ notification: Notification) {
        self.executeConfiguredCmd(force: false)
    }
    
    func executeConfiguredCmd(force: Bool) {
        displayChangeQueue.async {
            let displayCount = getDisplayCount()
            guard force || self.prevDisplayCount != displayCount else {
                NSLog("Display parameters changed but the number of displays hasn't changed. Noop. Current display count: %d", displayCount)
                return
            } 
            guard let cmd = self.userDefaults.string(forKey: ConfigKeys.cmd),
                  !cmd.isEmpty else {
                NSLog("User provided command is empty.")
                return
            }
                
            NSLog("New display count: %u. Force: %@, Calling command: %@", displayCount, force.description, cmd)
            let cmdOutput = executeCommand(cmd)
            NSLog("Command output: %@", cmdOutput)
            
            self.prevDisplayCount = displayCount
        }
    }
    
    @IBAction func executCmdManually(_ sender: Any) {
        executeConfiguredCmd(force: true)
    }
    
    @IBAction func showPreferences(_ sender: Any) {
        preferencesViewController.loadWindow()
        let preferencesWindow = preferencesViewController.window!
        if !preferencesWindow.isVisible {
            preferencesWindow.contentViewController?.representedObject = AppPreferences(command: userDefaults.string(forKey: ConfigKeys.cmd)!)
        }
        preferencesWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

func executeCommand(_ command: String) -> String {
    let env = ProcessInfo.processInfo.environment
    let currentPath = env["PATH"] ?? ""
    let executablePath = Bundle.main.bundlePath + "/Contents/MacOS" // Add embedded displayplacer to the path
    let path = executablePath + ":" + currentPath

    let stdouterr = Pipe()
    let task = Process()
    task.launchPath = "/bin/bash" // Use bash to parse the command line.
    task.environment = env
    task.environment!["PATH"] = path
    task.arguments = ["-c", command]
    task.standardOutput = stdouterr
    task.standardError = stdouterr
    task.launch()

    // TODO Change it to timed wait.
    task.waitUntilExit()
    
    _ = try? stdouterr.fileHandleForWriting.close()
    let data = stdouterr.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    
    return output
}

func getDisplayCount() -> UInt32 {
    var displayCount: UInt32 = 0
    CGGetOnlineDisplayList(UInt32.max, nil, &displayCount)
    return displayCount
}
