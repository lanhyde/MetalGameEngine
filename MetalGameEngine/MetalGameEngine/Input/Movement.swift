import Foundation

protocol Movement where Self: Transformable { }

extension Movement {
  var forward: float3 {
    normalize([sin(rotation.y), 0, cos(rotation.y)])
  }
  var right: float3 {
    [forward.z, forward.y, -forward.x]
  }
  
  func updateInput(deltaTime: Float) -> Transform {
    let input = InputController.shared
    var transform = Transform()
    let rotationAmount = deltaTime * Settings.rotationSpeed
    if input.keyPressed.contains(.leftArrow) {
      transform.rotation.y -= rotationAmount
    }
    if input.keyPressed.contains(.rightArrow) {
      transform.rotation.y += rotationAmount
    }
    var direction: float3 = .zero
    if input.keyPressed.contains(.keyW) {
      direction.z += 1
    }
    if input.keyPressed.contains(.keyS) {
      direction.z -= 1
    }
    if input.keyPressed.contains(.keyA) {
      direction.x -= 1
    }
    if input.keyPressed.contains(.keyD) {
      direction.x += 1
    }
    let translationAmount = deltaTime * Settings.translationSpeed
    if direction != .zero {
      direction = normalize(direction)
      transform.position += (direction.z * forward + direction.x * right) * translationAmount
    }
    return transform
  }
}
