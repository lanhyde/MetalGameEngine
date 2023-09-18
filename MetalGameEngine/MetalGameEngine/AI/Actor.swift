import simd

class Actor: Model {
  let steeringBehaviors: [Steering] = []
  let maxSpeed: Float
  let maxForce: Float
  let sqrMaxSpeed: Float
  var velocity: float3 = .zero
  let mass: Float
  let damping: Float
  var isPlanar: Bool
  var computeInterval: Float
  private var steeringForce: float3 = .zero
  private var acceleration: float3 = .zero
  private var timer: Float = 0
  
  init(name: String, mass: Float = 1, maxForce: Float = 100, maxSpeed: Float = 10, damping: Float = 0.9, computeInterval: Float = 0.2, isPlanar: Bool = true) {
    self.damping = damping
    self.mass = mass
    self.maxSpeed = maxSpeed
    self.maxForce = maxForce
    sqrMaxSpeed = maxSpeed * maxSpeed
    self.computeInterval = computeInterval
    self.isPlanar = isPlanar
    super.init(name: name)
  }
  
  override func update(deltaTime: Float) {
    timer += deltaTime
    steeringForce = .zero
    if timer > computeInterval {
      for steer in steeringBehaviors {
        if steer.isEnabled {
          steeringForce += steer.force * steer.weight
        }
      }
      steeringForce = float3.clampMagnitude(steeringForce, max: maxForce)
      acceleration = steeringForce / mass
      timer = 0
    }
  }
}
