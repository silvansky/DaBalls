//

import SceneKit

protocol BallArranger {
    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat)
}

class LineArranger: BallArranger {
    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat) {
        let w = rect.size.width
        let r = ballRadius
        let spaceForBalls = w * 0.9
        let spaceBetweenBalls = spaceForBalls / CGFloat(balls.count - 1)

        for (i, ball) in balls.enumerated() {
            let xOffset = CGFloat(i) * spaceBetweenBalls - spaceForBalls / 2
            let yOffset: CGFloat = CGFloat(i) * r / 3
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

class SineArranger: BallArranger {
    func arrangeBalls(_ balls: [Ball], rect: CGRect, ballRadius: CGFloat) {
        let twoPi = Double.pi * 2
        let anglePerBall = twoPi / Double(balls.count)
        let w = rect.size.width
        let r = min(rect.size.width, rect.size.height) * 0.25
        let spaceForBalls = w * 0.9
        let spaceBetweenBalls = spaceForBalls / CGFloat(balls.count - 1)
        for (i, ball) in balls.enumerated() {
            let theta = anglePerBall * Double(i) //+ Double.pi / 2
            let x = CGFloat(i) * spaceBetweenBalls - spaceForBalls / 2
            let y = r * sin(theta)
            ball.position = CGPoint(x: x, y: y)
        }
    }
}
