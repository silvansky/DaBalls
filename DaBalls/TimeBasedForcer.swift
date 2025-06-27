import SpriteKit

protocol TimeBasedForcer {
    func update(_ balls: [Ball], currentTime: TimeInterval)
}

class MassiveThing: TimeBasedForcer {
    private let center: CGPoint
    private let mass: CGFloat
    init(center: CGPoint = CGPoint(x: 0, y: 0), mass: CGFloat = 10) {
        self.center = center
        self.mass = mass
    }

    func update(_ balls: [Ball], currentTime: TimeInterval) {
        for ball in balls {
            ball.physicsBody?.applyForce(CGVector(dx: center.x - ball.position.x, dy: center.y - ball.position.y).normalized().scaled(by: mass))
        }
    }
}

class SetOfForcer: TimeBasedForcer {
    private let forcings: [TimeBasedForcer]

    init(forcings: [TimeBasedForcer]) {
        self.forcings = forcings
    }

    func update(_ balls: [Ball], currentTime: TimeInterval) {
        for forcer in forcings {
            forcer.update(balls, currentTime: currentTime)
        }
    }
}
