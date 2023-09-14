import Foundation


struct ArcballCamera: Camera {
  var transform = Transform()
  
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
  }
  
  let minDistance: Float = 0.01
  let maxDistance: Float = 40
  var target: float3 = [0, 0, 0]
  var distance: Float = 2.5
  
  var viewMatrix: float4x4 {
    let matrix: float4x4
    if target == position {
      matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
    } else {
      matrix = float4x4(eye: position, center: target, up: [0, 1, 0])
    }
    return matrix
  }
  
  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }
  
  mutating func update(deltaTime: Float) {
    let input = InputController.shared
    let scrollSensitivity = Settings.mouseScrollSensitivity
    distance -= (input.mouseScroll.x + input.mouseScroll.y) * scrollSensitivity
    distance = distance.clamp(lowerBound: minDistance, upperBound: maxDistance)
    input.mouseScroll = .zero
    
    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
      input.mouseDelta = .zero
    }
    let rotationMatrix = float4x4(rotationYXZ: [-rotation.x, rotation.y, 0])
    let distanceVector = float4(0, 0, -distance, 0)
    let rotatedVector = rotationMatrix * distanceVector
    position = target + rotatedVector.xyz
  }
}
