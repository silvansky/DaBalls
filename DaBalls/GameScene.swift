//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 =   0
    static let all: UInt32 =    UInt32.max
    static let ball: UInt32 =   0b1
    static let wall: UInt32 =   0b10
}

extension SKNode {
    func fadeOutAndRemove(_ fadeOutDuration: TimeInterval = 0.1) {
        let remove = SKAction.removeFromParent()
        let fadeOut = SKAction.fadeOut(withDuration: fadeOutDuration)
        run(SKAction.sequence([fadeOut, remove]))
    }
}

func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
{
    return (b-a) * fraction + a
}

struct ColorComponents {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alpha = CGFloat(0)
}

extension NSColor {
    func toComponents() -> ColorComponents {
        var components = ColorComponents()
        usingColorSpace(.sRGB)?.getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        return components
    }
}

extension SKAction {
    static func colorTransitionAction(fromColor: NSColor, toColor: NSColor, duration: Double = 0.1) -> SKAction
    {
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let startColorComponents = fromColor.toComponents()
            let endColorComponents = toColor.toComponents()
            let transColor = NSColor(red: lerp(a: startColorComponents.red, b: endColorComponents.red, fraction: fraction),
                                     green: lerp(a: startColorComponents.green, b: endColorComponents.green, fraction: fraction),
                                     blue: lerp(a: startColorComponents.blue, b: endColorComponents.blue, fraction: fraction),
                                     alpha: lerp(a: startColorComponents.alpha, b: endColorComponents.alpha, fraction: fraction))
            (node as? SKShapeNode)?.fillColor = transColor
        }
        )
    }
}

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

class GameScene: SKScene {
    private var border: SKShapeNode?
    private var balls: [Ball] = []
    private var defaultSpriteWidth: CGFloat { (size.width + size.height) * 0.03 }
    private let borderOffset: Double = 10
    private var borderFrame: CGRect { CGRectInset(frame, borderOffset, borderOffset) }

    private var audio: AudioController { AudioController.shared }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        physicsBody?.friction = 0
        physicsBody?.linearDamping = 0
        physicsBody?.angularDamping = 0

        createBorder()
        createBalls()
        arrangeBalls()
    }

    func start() {
        physicsWorld.gravity = CGVectorMake(0, -1.4)
        kickBalls()
    }

    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

extension GameScene {
    private func createBorder() {
        let shape = SKShapeNode(rect: borderFrame)

        shape.physicsBody = SKPhysicsBody(edgeLoopFrom: borderFrame)
        shape.physicsBody?.friction = 0
        shape.physicsBody?.isDynamic = true
        shape.physicsBody?.restitution = 0.99
        shape.physicsBody?.categoryBitMask = PhysicsCategory.wall
        shape.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        shape.physicsBody?.collisionBitMask = PhysicsCategory.ball
        shape.physicsBody?.usesPreciseCollisionDetection = true
        shape.zPosition = 0

        border = shape

        addChild(shape)
    }

    private func createBalls() {
        let count = 17
        let r = defaultSpriteWidth / 2
        for i in 0..<count {
            let ball = Ball(circleOfRadius: r)
            let c = 1.0 / Double(count) * Double(i)
            ball.backgroundColor = NSColor(red: c, green: 0, blue: 0, alpha: 1)
            ball.strokeColor = NSColor(red: 1 - c, green: 1 - c / 2, blue: 1 - c / 2, alpha: 1)
            ball.label = audio.nameForNote(i)
            //ball.glowWidth = 1

            ball.physicsBody = SKPhysicsBody(circleOfRadius: r)
            ball.physicsBody?.friction = 0
            ball.physicsBody?.allowsRotation = false
            //ball.physicsBody?.mass = CGFloat((i + 1)) / 100.0
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
            ball.physicsBody?.contactTestBitMask = PhysicsCategory.wall
            ball.physicsBody?.collisionBitMask = PhysicsCategory.wall
            ball.physicsBody?.usesPreciseCollisionDetection = true
            ball.physicsBody?.restitution = 0.99
            ball.physicsBody?.linearDamping = 0
            ball.physicsBody?.angularDamping = 0
            ball.noteNumber = i
            balls.append(ball)
            addChild(ball)
        }
    }

    private func arrangeBalls() {
        let w = size.width
        let r = defaultSpriteWidth / 2
        let spaceForBalls = w * 0.8
        let spaceBetweenBalls = spaceForBalls / CGFloat(balls.count - 1)

        for (i, ball) in balls.enumerated() {
            let xOffset = CGFloat(i) * spaceBetweenBalls - spaceForBalls / 2
            let yOffset = CGFloat(i) * r / 2
            ball.position = CGPointMake(xOffset, yOffset)
        }
    }

    private func kickBalls() {
        for (i, ball) in balls.enumerated() {
            let dx = -(50 + i * 5)
            let dy = 50
            //ball.physicsBody?.velocity = CGVector(dx: dx, dy: 0)
            ball.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func wallAndBall(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) -> Bool {
        return (bodyA.categoryBitMask | bodyB.categoryBitMask) == (PhysicsCategory.ball | PhysicsCategory.wall)
    }

    func ballForCollision(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) -> Ball? {
        return balls.first { ball in
            ball.physicsBody == bodyA || ball.physicsBody == bodyB
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if wallAndBall(firstBody, secondBody), let ball = ballForCollision(firstBody, secondBody) {
            audio.playNote(ball.noteNumber)
            ball.blink()
        }
    }
}
