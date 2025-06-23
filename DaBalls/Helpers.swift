//

import SceneKit
import GameplayKit

extension SKNode {
    func fadeOutAndRemove(_ fadeOutDuration: TimeInterval = 0.1) {
        let remove = SKAction.removeFromParent()
        let fadeOut = SKAction.fadeOut(withDuration: fadeOutDuration)
        run(SKAction.sequence([fadeOut, remove]))
    }
}

func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
{
    return (b-a) * fraction + a
}

struct ColorComponents {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alpha = CGFloat(0)
}

extension NSColor {
    func toComponents() -> ColorComponents {
        var components = ColorComponents()
        usingColorSpace(.sRGB)?.getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        return components
    }
}

extension SKAction {
    static func colorTransitionAction(fromColor: NSColor, toColor: NSColor, duration: Double = 0.1) -> SKAction
    {
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let startColorComponents = fromColor.toComponents()
            let endColorComponents = toColor.toComponents()
            let transColor = NSColor(red: lerp(a: startColorComponents.red, b: endColorComponents.red, fraction: fraction),
                                     green: lerp(a: startColorComponents.green, b: endColorComponents.green, fraction: fraction),
                                     blue: lerp(a: startColorComponents.blue, b: endColorComponents.blue, fraction: fraction),
                                     alpha: lerp(a: startColorComponents.alpha, b: endColorComponents.alpha, fraction: fraction))
            (node as? SKShapeNode)?.fillColor = transColor
        }
        )
    }
}

extension NSGradient {
    class var circularRainbow: NSGradient {
        return NSGradient(colors: [
            .RGB(250, 0, 0),
            .RGB(0, 0, 250),
            .RGB(10, 220, 10),
            .RGB(0, 0, 250),
            .RGB(250, 0, 0)
        ])!
    }

    class var linearRainbow: NSGradient {
        return NSGradient(colors: [
            .RGB(250, 0, 0),
            .RGB(0, 250, 0),
            .RGB(0, 0, 250),
        ])!
    }
}

extension NSColor {
    static func RGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> NSColor {
        return NSColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }

    static func RGBA(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> NSColor {
        return NSColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
