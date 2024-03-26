//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    @IBAction func start(_ sender: Any) {
        (contentViewController as? ViewController)?.start()
    }
}
