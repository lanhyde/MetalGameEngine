import simd

class Actor: Model {
  var steeringBehaviors: [Steering] = []
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
  private var epsilon: Float = 0.00001
  
  init(name: String, mass: Float = 1, maxForce: Float = 20, maxSpeed: Float = 2, damping: Float = 0.9, computeInterval: Float = 0.2, isPlanar: Bool = true) {
    self.damping = damping
    self.mass = mass
    self.maxSpeed = maxSpeed
    self.maxForce = maxForce
    sqrMaxSpeed = maxSpeed * maxSpeed
    self.computeInterval = computeInterval
    self.isPlanar = isPlanar
    super.init(name: name)
  }
  
  func appendSteering(_ steering: Steering) {
    steeringBehaviors.append(steering)
  }
  
  override func update(deltaTime: Float) {
    updateKinematic(deltaTime)
    updateTransform(deltaTime)
  }
  
  private func updateKinematic(_ deltaTime: Float) {
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
  
  private func updateTransform(_ deltaTime: Float) {
    velocity += acceleration * deltaTime
    if simd_length_squared(velocity) > sqrMaxSpeed {
      velocity = normalize(velocity) * maxSpeed
    }
    var moveDistance = velocity * deltaTime * 0.1
    
    if isPlanar {
      velocity.y = 0
      moveDistance.y = 0
    }
    
    transform.position += moveDistance
    
    if length_squared(velocity) > epsilon {
      var newForward = float3.slerp(from: forward, to: velocity, damping * deltaTime)
      if isPlanar {
        newForward.y = 0
      }
//      print("!!!newForward: \(newForward)")
//      let forward = float3([sin(transform.rotation.y), 0, cos(transform.rotation.y)])
//      print("!!!forward before: \(forward)")
//      let prod = simd_dot(float3([0, 0, 1]), newForward)
//      let theta = acos(prod)
//      transform.rotation = float3(x: 0, y: theta, z: 0)
//      
//      print("!!!forward after: \(float3([sin(transform.rotation.y), 0, cos(transform.rotation.y)]))")
    }
  }
}
