import MetalKit

struct GameScene {
  var models: [Model] = []
  var camera = PlayerCamera()
  var defaultView: Transform {
    Transform(position: [1.32, 2.96, 35.38], rotation: [-0.16, 3.09, 0])
  }
  var lighting = SceneLighting()
  let skybox: Skybox?
  
  init() {
    skybox = Skybox(textureName: "sky")
    camera.transform = defaultView
  }
  
  mutating func update(size: CGSize) {
    camera.update(size: size)
  }
  
  mutating func update(deltaTime: Float) {
    let input = InputController.shared
    
    if input.keyPressed.contains(.one) {
      camera.transform = Transform()
      input.keyPressed.remove(.one)
    }
    if input.keyPressed.contains(.two) {
      camera.transform = defaultView
      input.keyPressed.remove(.two)
    }
    
    let positionYDelta = (input.mouseScroll.x + input.mouseScroll.y) * Settings.mouseScrollSensitivity
    let minY: Float = -1
    if camera.position.y + positionYDelta > minY {
      camera.position.y += positionYDelta
    }
    input.mouseScroll = .zero
    
    camera.update(deltaTime: deltaTime)
  }
}
