import Foundation

struct PlayerCamera: Camera, Movement {
  var transform = Transform()
  
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 1.0
  var far: Float = 100
  
  var projectionMatrix: float4x4 {
    float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
  }
  
  var viewMatrix: float4x4 {
    let rotateMatrix = float4x4(rotationYXZ: [-rotation.x, rotation.y, 0])
    return (float4x4(translation: position) * rotateMatrix).inverse
  }
  
  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }
  
  mutating func update(deltaTime: Float) {
    let transform = updateInput(deltaTime: deltaTime)
    rotation += transform.rotation
    position += transform.position
    let input = InputController.shared
    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      rotation.x = rotation.x.clamp(lowerBound: -.pi / 2, upperBound: .pi / 2)
      input.mouseDelta = .zero
    }
  }
}
