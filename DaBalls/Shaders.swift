//

import SpriteKit

class EchoShader: SKShader {
    private let prevFrameUniform = SKUniform(name: "prevframe", texture: SKTexture(vectorNoiseWithSmoothness: 1, size: CGSize(width: 100, height: 100)))
    override init() {
        let source = try? String.init(contentsOf: Bundle.main.url(forResource: "main_shader", withExtension: "fsh")!)
        super.init(source: source ?? "", uniforms: [prevFrameUniform])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTexture(_ texture: SKTexture) {
        prevFrameUniform.textureValue = texture
    }
}

class Shaders {
    static let main: EchoShader = EchoShader()
}
