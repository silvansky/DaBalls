import SpriteKit

protocol GravityAdjustment {
    func update(_ currentTime: TimeInterval) -> CGVector
}

class FixedGravity: GravityAdjustment {
    private let initialGravity: CGVector

    init(initialGravity: CGVector) {
        self.initialGravity = initialGravity
    }

    func update(_ currentTime: TimeInterval) -> CGVector {
        return initialGravity
    }
}

class SineGravity: GravityAdjustment {
    private let baseGravity: CGVector
    private var startTime: TimeInterval = -1
    private let frequency: Double

    init(baseGravity: CGVector, frequency: Double = 0.25) {
        self.baseGravity = baseGravity
        self.frequency = frequency
    }

    func update(_ currentTime: TimeInterval) -> CGVector {
        if startTime < 0 {
            startTime = currentTime
            return CGVectorMake(0, 0)
        }

        let deltaTime = currentTime - startTime

        let sineValue = CGFloat(sin(2 * Double.pi * frequency * deltaTime))
        let adjustedGravity = CGVector(dx: baseGravity.dx * sineValue, dy: baseGravity.dy * sineValue)

        return adjustedGravity
    }
}

class RotatingGravity: GravityAdjustment {
    private let baseGravity: CGVector
    private var startTime: TimeInterval = -1
    private let frequency: Double

    init(baseGravity: CGVector, frequency: Double = 0.2) {
        self.baseGravity = baseGravity
        self.frequency = frequency
    }

    func update(_ currentTime: TimeInterval) -> CGVector {
        if startTime < 0 {
            startTime = currentTime
            return CGVectorMake(0, 0)
        }

        let deltaTime = currentTime - startTime

        let angle = CGFloat(2 * Double.pi * frequency * deltaTime)
        let rotatedGravity = CGVector(dx: baseGravity.dx * cos(angle) - baseGravity.dy * sin(angle),
                                      dy: baseGravity.dx * sin(angle) + baseGravity.dy * cos(angle))

        return rotatedGravity
    }
}
