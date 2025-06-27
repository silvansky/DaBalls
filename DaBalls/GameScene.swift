//

import SpriteKit
import GameplayKit
import AudioKit

class GameScene: SKScene {
    private struct PhysicsCategory {
        static let none: UInt32 =   0
        static let all: UInt32 =    UInt32.max
        static let ball: UInt32 =   0b1
        static let wall: UInt32 =   0b10
    }

    private var border: SKShapeNode?
    private var balls: [Ball] = []
    private var defaultSpriteWidth: CGFloat { (size.width + size.height) * 0.01 }
    private let borderOffset: Double = 10
    private var borderFrame: CGRect { CGRectInset(frame, borderOffset, borderOffset) }

    private var audio: AudioController { AudioController.shared }

    private let arranger: BallArranger = LineArranger(heightCoefficient: 0)
    private let initialKicker: BallKicker = LinearBallKicker(vector: CGVector(dx: 0, dy: 1))//AngularSpeedBallKicker(angularSpeed: 0.02, center: .zero)
    private let coloring: BallColoring = GradientBallColoring(gradient: .circularRainbow)
    private var gravityAdjustment: GravityAdjustment? = nil
    private var timeBasedKicker: TimeBasedKicker? = nil
    private var timeBasedForcer: TimeBasedForcer? = nil

    private let ballCount = 50
    private let restitution: CGFloat = 1//0.99

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

        reset()

        Settings.enableLogging = false
    }

    override func didMove(to view: SKView) {
        shouldEnableEffects = true
        shader = Shaders.motionBlur
    }

    func start() {
        reset()
        gravityAdjustment = FixedGravity(initialGravity: CGVectorMake(0, -0.4))
        //timeBasedKicker = PeriodicKickToCenter(frequency: 4, kickForce: 2)
        timeBasedForcer =
        SetOfForcer(forcings: [
            MassiveThing(center: CGPoint(x: 0, y: borderFrame.width / 4.0), mass: 0.6),
            MassiveThing(center: CGPoint(x: 0, y: -borderFrame.width / 4.0), mass: 0.6)
        ])
        kickBalls()
        for ball in balls {
            audio.switchOscillator(ball.identifier)
        }
    }

    func reset() {
        physicsWorld.gravity = CGVectorMake(0, 0)
        gravityAdjustment = nil
        timeBasedKicker = nil
        timeBasedForcer = nil
        for ball in balls {
            ball.physicsBody?.velocity = CGVectorMake(0, 0)
        }
        arrangeBalls()
        for ball in balls {
            audio.stopOscillator(ball.identifier)
        }
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
        if let gravity = gravityAdjustment?.update(currentTime) {
            physicsWorld.gravity = gravity
        }
        timeBasedKicker?.update(balls, currentTime: currentTime)
        timeBasedForcer?.update(balls, currentTime: currentTime)
    }

    override func didFinishUpdate() {
        if let texture = view?.texture(from: self) {
            Shaders.motionBlur.setTexture(texture)
        }

        for ball in balls {
            audio.updateOscillator(ball.identifier, position: ball.position, rect: borderFrame)
        }
    }
}

extension GameScene {
    private func createBorder() {
        let shape = SKShapeNode(circleOfRadius: borderFrame.width / 2)
        shape.position = CGPoint.zero

        shape.physicsBody = SKPhysicsBody(edgeLoopFrom: CGPath(ellipseIn: borderFrame, transform: nil))
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
            ball.identifier = i
            audio.addOscillator(for: i)
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
        initialKicker.kickBalls(balls)
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
            let pan = ball.position.x / (borderFrame.width / 2)
            let maxSpeed: CGFloat = 500
            let speed = min(ball.physicsBody?.velocity.length ?? 0, maxSpeed)
            let velocity: MIDIVelocity = MIDIVelocity((speed / maxSpeed) * CGFloat(MIDIVelocity.max))
            //audio.switchOscillator(ball.identifier)
            audio.playNote(ball.noteNumber, pan: Float(pan), velocity: velocity)
            ball.blink()
        }
    }
}
