import Foundation

protocol Movement where Self: Transformable { }

extension Movement {
  func updateInput(deltaTime: Float) -> Transform {
    let input = InputController.shared
    var transform = Transform()
    let rotationAmount = deltaTime * Settings.rotationSpeed
    if input.keysPressed.contains(.leftArrow) {
      transform.rotation.y -= rotationAmount
    }
    if input.keysPressed.contains(.rightArrow) {
      transform.rotation.y += rotationAmount
    }
    var direction: float3 = .zero
    if input.keysPressed.contains(.keyW) {
      direction.z += 1
    }
    if input.keysPressed.contains(.keyS) {
      direction.z -= 1
    }
    if input.keysPressed.contains(.keyA) {
      direction.x -= 1
    }
    if input.keysPressed.contains(.keyD) {
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
