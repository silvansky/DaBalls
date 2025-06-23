//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private struct PhysicsCategory {
        static let none: UInt32 =   0
        static let all: UInt32 =    UInt32.max
        static let ball: UInt32 =   0b1
        static let wall: UInt32 =   0b10
    }

    private var border: SKShapeNode?
    private var balls: [Ball] = []
    private var defaultSpriteWidth: CGFloat { (size.width + size.height) * 0.03 }
    private let borderOffset: Double = 10
    private var borderFrame: CGRect { CGRectInset(frame, borderOffset, borderOffset) }

    private var audio: AudioController { AudioController.shared }

    private let arranger: BallArranger = LineArranger()
    private let kicker: BallKicker = LinearBallKicker(vector: CGVectorMake(30, 0))
    private let coloring: BallColoring = GradientBallColoring(gradient: .linearRainbow)

    private let ballCount = 7
    private let restitution: CGFloat = 0.999

    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        physicsWorld.speed = 4

        physicsBody?.friction = 0
        physicsBody?.linearDamping = 0
        physicsBody?.angularDamping = 0

        createBorder()
        createBalls()
        colorBalls()
        arrangeBalls()
    }

    override func didMove(to view: SKView) {
        shouldEnableEffects = true
        shader = Shaders.motionBlur
    }

    func start() {
        reset()
        physicsWorld.gravity = CGVectorMake(0, -0.4)
        kickBalls()
    }

    func reset() {
        physicsWorld.gravity = CGVectorMake(0, 0)
        for ball in balls {
            ball.physicsBody?.velocity = CGVectorMake(0, 0)
        }
        arrangeBalls()
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
    }

    override func didFinishUpdate() {
        if let texture = view?.texture(from: self) {
            Shaders.motionBlur.setTexture(texture)
        }
    }
}

extension GameScene {
    private func createBorder() {
        let shape = SKShapeNode(rect: borderFrame)

        shape.physicsBody = SKPhysicsBody(edgeLoopFrom: borderFrame)
        shape.physicsBody?.friction = 0
        shape.physicsBody?.isDynamic = true
        shape.physicsBody?.restitution = restitution
        shape.physicsBody?.categoryBitMask = PhysicsCategory.wall
        shape.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        shape.physicsBody?.collisionBitMask = PhysicsCategory.ball
        shape.physicsBody?.usesPreciseCollisionDetection = true
        shape.zPosition = 0

        border = shape

        addChild(shape)
    }

    private func createBalls() {
        let r = defaultSpriteWidth / 2
        for i in 0..<ballCount {
            let ball = Ball(circleOfRadius: r)
            //ball.label = audio.nameForNote(i)

            ball.isAntialiased = true
            ball.physicsBody = SKPhysicsBody(circleOfRadius: r)
            ball.physicsBody?.friction = 0
            ball.physicsBody?.allowsRotation = false
            //ball.physicsBody?.mass = CGFloat((i + 1)) / 100.0
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
            ball.physicsBody?.contactTestBitMask = PhysicsCategory.wall
            ball.physicsBody?.collisionBitMask = PhysicsCategory.wall
            ball.physicsBody?.usesPreciseCollisionDetection = true
            ball.physicsBody?.restitution = restitution
            ball.physicsBody?.linearDamping = 0
            ball.physicsBody?.angularDamping = 0
            ball.noteNumber = i
            ball.lineWidth = 0.001
            balls.append(ball)
            addChild(ball)
        }
    }

    private func colorBalls() {
        coloring.colorBalls(balls)
    }

    private func arrangeBalls() {
        arranger.arrangeBalls(balls, rect: frame, ballRadius: defaultSpriteWidth / 2)
    }

    private func kickBalls() {
        kicker.kickBalls(balls)
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
