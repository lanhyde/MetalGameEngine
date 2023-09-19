import simd

class WanderSteering: Steering {
  let wanderRadius: Float
  let wanderDistance: Float
  let wanderJitter: Float
  let isPlanar: Bool
  var desiredVelocity: float3
  private let maxSpeed: Float
  private let actor: Actor
  var circleTarget: float3
  var wanderTarget: float3
  
  var weight: Float
  var isEnabled: Bool
  var force: float3 {
    var randomDisplacement = float3(x: wanderJitter * 2 * (Float.random(in: 0..<1) - 0.5), y: wanderJitter * 2 * (Float.random(in: 0..<1) - 0.5), z: wanderJitter * 2 * (Float.random(in: 0..<1) - 0.5))
    if isPlanar {
      randomDisplacement.y = 0
    }
    circleTarget += randomDisplacement
    circleTarget = wanderRadius * normalize(circleTarget)
    wanderTarget = normalize(actor.velocity) * wanderDistance + circleTarget + actor.position
    desiredVelocity = normalize(wanderTarget - actor.position) * maxSpeed
    return desiredVelocity - actor.velocity
  }
  
  init(actor: Actor, weight: Float = 1) {
    wanderRadius = 10
    wanderDistance = 20
    wanderJitter = 0.5
    desiredVelocity = .zero
    isEnabled = true
    self.weight = weight
    self.actor = actor
    maxSpeed = actor.maxSpeed
    isPlanar = actor.isPlanar
    circleTarget = float3(wanderRadius * 0.707, 0, wanderRadius * 0.707)
    wanderTarget = .zero
  }
}
