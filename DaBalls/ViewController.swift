//

import Cocoa
import SpriteKit
import GameplayKit
import ReplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!

    private var gameScene: GameScene?
    private var recorder: RPScreenRecorder { RPScreenRecorder.shared() }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            view.preferredFramesPerSecond = 120
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit

                // Present the scene
                view.presentScene(scene)

                gameScene = scene as? GameScene
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    func start() {
        gameScene?.start()
    }

    func startScreenRecording() {
        guard !recorder.isRecording else { return }
        recorder.startRecording { error in
            if let error {
                print("Failed to start recording: \(error)")
                self.presentError(error)
            } else {
                print("Recording started...")
            }
        }
    }

    func stopScreenRecording() {
        guard recorder.isRecording else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = dateFormatter.string(from: Date())

        let movies = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first!
        let recordingUrl = movies.appendingPathComponent("daballs_\(date).mov", conformingTo: UTType.movie)
        print("Saving recording to \(recordingUrl)")
        Task {
            do {
                try await recorder.stopRecording(withOutput: recordingUrl)
            } catch {
                print("error: \(error)")
                presentError(error)
            }
        }
    }
}

extension ViewController: RPScreenRecorderDelegate {

}
