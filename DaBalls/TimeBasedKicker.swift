import SpriteKit

protocol TimeBasedKicker {
    func update(_ balls: [Ball], currentTime: TimeInterval)
}

class PeriodicKickToCenter: TimeBasedKicker {
    private let frequency: Double
    private let kickForce: CGFloat
    private var lastKickTime: TimeInterval = -1

    init(frequency: Double, kickForce: CGFloat = 40) {
        self.frequency = frequency
        self.kickForce = kickForce
    }

    func update(_ balls: [Ball], currentTime: TimeInterval) {
        if lastKickTime < 0 || currentTime - lastKickTime >= frequency {
            lastKickTime = currentTime
            let center = CGPoint(x: 0, y: 0) // Assuming center is at (0, 0)
            for ball in balls {
                let direction = CGVector(dx: center.x - ball.position.x, dy: center.y - ball.position.y)
                let impulse = direction.normalized().scaled(by: kickForce)
                ball.physicsBody?.applyImpulse(impulse)
            }
        }
    }
}

class PeriodicKickToDirection: TimeBasedKicker {
    private let frequency: Double
    private let kickForce: CGFloat
    private var lastKickTime: TimeInterval = -1
    private let direction: CGVector

    init(frequency: Double, kickForce: CGFloat = 40, direction: CGVector) {
        self.frequency = frequency
        self.kickForce = kickForce
        self.direction = direction.normalized()
    }

    func update(_ balls: [Ball], currentTime: TimeInterval) {
        // skip first update
        if lastKickTime < 0 {
            lastKickTime = currentTime
            return
        }
        if currentTime - lastKickTime >= frequency {
            lastKickTime = currentTime
            for ball in balls {
                ball.physicsBody?.applyImpulse(direction.normalized().scaled(by: kickForce))
            }
        }
    }
}
