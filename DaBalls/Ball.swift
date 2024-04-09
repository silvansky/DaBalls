//

import SpriteKit

class Ball: SKShapeNode {
    var noteNumber: Int = 42
    var label: String = "" {
        didSet {
            labelNode.text = label
            addChild(labelNode)
            labelNode.position = .zero
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .center
        }
    }

    var backgroundColor: NSColor = .black {
        didSet {
            fillColor = backgroundColor
        }
    }

    var labelColor: NSColor = .white {
        didSet {
            labelNode.color = labelColor
        }
    }

    private var labelNode: SKLabelNode = .init()

    func blink() {
        let currentColor = backgroundColor
        let targetColor = NSColor.white
        let blinkIn = SKAction.colorTransitionAction(fromColor: currentColor, toColor: targetColor, duration: 0.01)
        let blinkOut = SKAction.colorTransitionAction(fromColor: targetColor, toColor: currentColor, duration: 0.1)
        run(SKAction.sequence([blinkIn, blinkOut]))
    }
}
