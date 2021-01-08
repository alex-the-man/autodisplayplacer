//
//  ViewController.swift
//  autodisplayplacer
//
//  Created by Alex Man on 1/5/21.
//

import Cocoa

public class AppPreferences: NSObject {
    @objc dynamic var command: String

    public init(command: String) {
        self.command = command
    }
}

class PreferencesViewController: NSViewController {
    @IBOutlet var commandTextView: NSTextView!
    @IBOutlet var executeButton: NSButton!
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet var progressIndicator: NSProgressIndicator!
        
    override func viewDidLoad() {
        self.commandTextView.isAutomaticQuoteSubstitutionEnabled = false;
        self.commandTextView.isAutomaticDashSubstitutionEnabled = false;
        self.commandTextView.isAutomaticTextReplacementEnabled = false;
    }
    
    override func viewWillAppear() {
        outputTextView.string = ""
    }
    
    override func viewDidDisappear() {
        NSUserDefaultsController.shared.revert(nil)
    }

    @IBAction func execute(_ sender: Any) {
        self.progressIndicator.startAnimation(nil)
        let cmd = self.commandTextView.string
        self.outputTextView.string = ""
        self.executeButton.isEnabled = false
        DispatchQueue.global(qos: .background).async {
            let output = executeCommand(cmd)
            DispatchQueue.main.async {
                self.outputTextView.string = output.isEmpty ? "<no output>" : output
                self.progressIndicator.stopAnimation(nil)
                self.executeButton.isEnabled = true
            }
        }
    }
}
