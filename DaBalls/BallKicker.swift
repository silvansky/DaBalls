import SpriteKit

protocol BallKicker {
    func kickBalls(_ balls: [Ball])
}

class NoopBallKicker: BallKicker {
    func kickBalls(_ balls: [Ball]) {}
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
            let k = 1 + CGFloat(i) * factor
            ball.physicsBody?.applyImpulse(CGVectorMake(vector.dx * k, vector.dy * k))
        }
    }
}

class RadialBallKicker: BallKicker {
    let force: CGFloat

    init(force: CGFloat = -100) {
        self.force = force
    }

    func kickBalls(_ balls: [Ball]) {
        let twoPi = Double.pi * 2
        let anglePerBall = twoPi / Double(balls.count)
        for (i, ball) in balls.enumerated() {
            let theta = anglePerBall * Double(i) + Double.pi / 2
            let x = force * cos(theta)
            let y = force * sin(theta)
            ball.physicsBody?.applyImpulse(CGVectorMake(x, y))
        }
    }
}

class CircularBallKicker: BallKicker {
    let force: CGFloat

    init(force: CGFloat = -100) {
        self.force = force
    }

    func kickBalls(_ balls: [Ball]) {
        for ball in balls {
            // calc angle between ball and 0-0
            let angle = atan2(ball.position.y, ball.position.x)
            // add pi/2
            let theta = angle + CGFloat.pi / 2

            // calc vector
            let x = force * cos(theta)
            let y = force * sin(theta)
            ball.physicsBody?.applyImpulse(CGVectorMake(x, y))
        }
    }
}

class AngularSpeedBallKicker: BallKicker {
    let angularSpeed: CGFloat
    let center: CGPoint

    init(angularSpeed: CGFloat = -10, center: CGPoint = .zero) {
        self.angularSpeed = angularSpeed
        self.center = center
    }

    func kickBalls(_ balls: [Ball]) {
        for ball in balls {
            let velocity = linearVelocity(angularSpeed: angularSpeed, center: center, point: ball.position)
            ball.physicsBody?.applyImpulse(velocity)
        }
    }

    private func linearVelocity(angularSpeed: Double, center: CGPoint, point: CGPoint) -> CGVector {
        let rx = point.x - center.x
        let ry = point.y - center.y

        let vx = -angularSpeed * ry
        let vy = angularSpeed * rx

        return CGVector(dx: vx, dy: vy)
    }
}
