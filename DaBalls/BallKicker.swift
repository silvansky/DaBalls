//

import SpriteKit
import GameplayKit

protocol BallKicker {
    func kickBalls(_ balls: [Ball])
}

class LinearBallKicker: BallKicker {
    let vector: CGVector

    init(vector: CGVector) {
        self.vector = vector
    }

    func kickBalls(_ balls: [Ball]) {
        for ball in balls {
            ball.physicsBody?.applyImpulse(vector)
        }
    }
}

class ProgressiveLinearBallKicker: BallKicker {
    let vector: CGVector
    let factor: CGFloat

    init(vector: CGVector, factor: CGFloat) {
        self.vector = vector
        self.factor = factor
    }

    func kickBalls(_ balls: [Ball]) {
        for (i, ball) in balls.enumerated() {
            let k = CGFloat(i) * factor
            ball.physicsBody?.applyImpulse(CGVectorMake(vector.dx * k, vector.dy * k))
        }
    }
}
