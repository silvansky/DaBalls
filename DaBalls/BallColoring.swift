//

import SpriteKit
import GameplayKit

protocol BallColoring {
    func colorBalls(_ balls: [Ball])
}

class RedBallColoring: BallColoring {
    func colorBalls(_ balls: [Ball]) {
        for (i, ball) in balls.enumerated() {
            let c = 1.0 / Double(balls.count) * Double(i)
            ball.backgroundColor = NSColor(red: c, green: 0, blue: 0, alpha: 1)
            ball.strokeColor = NSColor(red: 1 - c, green: 1 - c / 2, blue: 1 - c / 2, alpha: 1)
        }
    }
}

class GradientBallColoring: BallColoring {
    private let gradient: NSGradient

    init(gradient: NSGradient = NSGradient(colors: [.red, .purple, .blue, .green, .red])!) {
        self.gradient = gradient
    }

    func colorBalls(_ balls: [Ball]) {
        guard balls.count > 1 else {
            for ball in balls {
                ball.backgroundColor = gradient.interpolatedColor(atLocation: 0)
                ball.strokeColor = .white
            }
            return
        }

        for (i, ball) in balls.enumerated() {
            let location: CGFloat = CGFloat(i) / CGFloat(balls.count - 1)
            ball.backgroundColor = gradient.interpolatedColor(atLocation: location)
            ball.strokeColor = .white
        }
    }
}
