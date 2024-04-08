//

import Cocoa

class MainWindowController: NSWindowController {

    var vc: ViewController { contentViewController as! ViewController }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    @IBAction func start(_ sender: Any) {
        vc.start()
    }

    @IBAction func startScreenRecording(_ sender: Any) {
        vc.startScreenRecording()
    }

    @IBAction func stopScreenRecording(_ sender: Any) {
        vc.stopScreenRecording()
    }
}
