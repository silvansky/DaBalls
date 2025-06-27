//

import SceneKit

protocol BallArranger {
    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat)
}

class LineArranger: BallArranger {
    private let heightCoefficient: CGFloat
    init(heightCoefficient: CGFloat = 1) {
        self.heightCoefficient = heightCoefficient
    }

    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat) {
        let w = rect.size.width
        let spaceForBalls = w * 0.8
        let spaceBetweenBalls = spaceForBalls / CGFloat(balls.count - 1)
        let verticalSpacing = heightCoefficient * (rect.size.height / 2.5) / CGFloat(balls.count - 1)

        for (i, ball) in balls.enumerated() {
            let xOffset = CGFloat(i) * spaceBetweenBalls - spaceForBalls / 2
            let yOffset: CGFloat = CGFloat(i) * verticalSpacing
            ball.position = CGPointMake(xOffset, yOffset)
        }
    }
}

class CircularArranger: BallArranger {
    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat) {
        let twoPi = Double.pi * 2
        let anglePerBall = twoPi / Double(balls.count)
        let r = min(rect.size.width, rect.size.height) * 0.25
        for (i, ball) in balls.enumerated() {
            let theta = anglePerBall * Double(i) + Double.pi / 2
            let x = r * cos(theta)
            let y = r * sin(theta)
            ball.position = CGPoint(x: x, y: y)
        }
    }
}

class SpiralArranger: BallArranger {
    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat) {
        let twoPi = Double.pi * 3
        let anglePerBall = twoPi / Double(balls.count)
        let r0 = min(rect.size.width, rect.size.height) * 0.1
        let k: CGFloat = 0.07
        for (i, ball) in balls.enumerated() {
            let br = r0 + k * CGFloat(i) * r0
            let theta = anglePerBall * Double(i) + Double.pi / 2
            let x = br * cos(theta)
            let y = br * sin(theta)
            ball.position = CGPoint(x: x, y: y)
        }
    }
}

class SineArranger: BallArranger {
    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat) {
        let twoPi = Double.pi * 2
        let anglePerBall = twoPi / Double(balls.count)
        let w = rect.size.width
        let r = min(rect.size.width, rect.size.height) * 0.15
        let spaceForBalls = w * 0.9
        let spaceBetweenBalls = spaceForBalls / CGFloat(balls.count - 1)
        for (i, ball) in balls.enumerated() {
            let theta = anglePerBall * Double(i) * 2
            let x = CGFloat(i) * spaceBetweenBalls - spaceForBalls / 2
            let y = r * sin(theta)
            ball.position = CGPoint(x: x, y: y)
        }
    }
}
