import MetalKit

struct GameScene {
  var models: [Model] = []
  var camera = PlayerCamera()
  var defaultView: Transform {
    Transform(position: [1.32, 2.96, 35.38], rotation: [-0.16, 3.09, 0])
  }
  var lighting = SceneLighting()
  let skybox: Skybox?
  var terrain: Terrain?
  var cottage: Model
  var water: Water?
  
  var swan: Model
  init() {
    skybox = Skybox(textureName: "sky")
    water = Water()
    water?.position = [0, -1, 0]
    
    terrain = Terrain(name: "terrain.obj")
    terrain?.tiling = 12
    terrain?.position = [0, 3, 0]
    cottage = Model(name: "house.obj")
    swan = Model(name: "swan.obj")
    camera.transform = defaultView
    
    cottage.position = [0, 0.4, 10]
    swan.position = [0, -1.05, 35]
    cottage.rotation.y = 0.2
    models = [cottage, swan]
  }
  
  mutating func update(size: CGSize) {
    camera.update(size: size)
  }
  
  mutating func update(deltaTime: Float) {
    water?.update(deltaTime: deltaTime)
    let input = InputController.shared
    
    if input.keysPressed.contains(.one) {
      camera.transform = Transform()
      input.keysPressed.remove(.one)
    }
    if input.keysPressed.contains(.two) {
      camera.transform = defaultView
      input.keysPressed.remove(.two)
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
