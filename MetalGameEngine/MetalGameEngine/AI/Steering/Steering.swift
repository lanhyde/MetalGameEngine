import simd

protocol Steering {
  var weight: Float { get set }
  var force: float3 { get }
  var isEnabled: Bool { get set }
}
