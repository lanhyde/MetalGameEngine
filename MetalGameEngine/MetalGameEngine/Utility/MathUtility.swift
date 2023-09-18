import simd
import CoreGraphics

typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>
typealias quaternion = simd_quatf

extension Float {
  var radiansToDegrees: Float {
    (self / Self.pi) * 180
  }
  var degreesToRadians: Float {
    (self / 180) * Self.pi
  }
  
  func clamp(lowerBound: Float, upperBound: Float) -> Float {
    min(max(self, lowerBound), upperBound)
  }
}

extension float3 {
  static func clampMagnitude(_ vec: float3, max threshold: Float) -> float3 {
    if simd_length(vec) <= threshold {
      return vec
    }
    let unitVec = normalize(vec)
    return unitVec * threshold
  }
  static func slerp(from start: float3, to end: float3, _ percent: Float) -> float3 {
    var prod = simd_dot(start, end)
    prod = prod.clamp(lowerBound: -1.0, upperBound: 1.0)
    let theta = acos(prod) * percent
    var relativeVec = end - start * prod
    relativeVec = normalize(relativeVec)
    
    return start * cos(theta) + relativeVec * sin(theta)
  }
}
extension float4x4 {
  init(translation: float3) {
    let matrix = float4x4(
      [            1,             0,             0, 0],
      [            0,             1,             0, 0],
      [            0,             0,             1, 0],
      [translation.x, translation.y, translation.z, 1]
    )
    self = matrix
  }
  
  init(scaling: float3) {
    let matrix = float4x4(
      [scaling.x,         0,         0, 0],
      [        0, scaling.y,         0, 0],
      [        0,         0, scaling.z, 0],
      [        0,         0,         0, 1]
    )
    self = matrix
  }
  
  init (scaling: Float) {
    self = matrix_identity_float4x4
    columns.3.w = 1 / scaling
  }
  
  init(rotationX angle: Float) {
    let matrix = float4x4(
      [1,           0,          0, 0],
      [0,  cos(angle), sin(angle), 0],
      [0, -sin(angle), cos(angle), 0],
      [0,           0,          0, 1]
      )
    self = matrix
  }
  
  init(rotationY angle: Float) {
    let matrix = float4x4(
      [cos(angle), 0, -sin(angle), 0],
      [         0, 1,           0, 0],
      [sin(angle), 0,  cos(angle), 0],
      [         0, 0,           0, 1]
      )
    self = matrix
  }
  
  init(rotationZ angle: Float) {
    let matrix = float4x4(
      [ cos(angle), sin(angle), 0, 0],
      [-sin(angle), cos(angle), 0, 0],
      [          0,          0, 1, 0],
      [          0,          0, 0, 1]
    )
    self = matrix
  }
  
  init(rotation angle: float3) {
    let rotationX = float4x4(rotationX: angle.x)
    let rotationY = float4x4(rotationY: angle.y)
    let rotationZ = float4x4(rotationZ: angle.z)
    self = rotationX * rotationY * rotationZ
  }
  
  init(rotationYXZ angle: float3) {
    let rotationX = float4x4(rotationX: angle.x)
    let rotationY = float4x4(rotationY: angle.y)
    let rotationZ = float4x4(rotationZ: angle.z)
    self = rotationY * rotationX * rotationZ
  }
  
  static var identity: float4x4 {
    matrix_identity_float4x4
  }
  
  var upperLeft: float3x3 {
    let x = columns.0.xyz
    let y = columns.1.xyz
    let z = columns.2.xyz
    return float3x3(columns: (x, y, z))
  }
  
  // MARK: Left handed projection matrix
  init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
    let y = 1 / tan(fov * 0.5)
    let x = y / aspect
    let z = lhs ? far / (far - near) : far / (near - far)
    let X = float4(x, 0, 0, 0)
    let Y = float4(0, y, 0, 0)
    let Z = lhs ? float4(0, 0, z, 1) : float4(0, 0, z, -1)
    let W = lhs ? float4(0, 0, z * -near, 0) : float4(0, 0, z * near, 0)
    self.init()
    columns = (X, Y, Z, W)
  }
  
  // left-handed LookAt
  init(eye: float3, center: float3, up: float3) {
    let z = normalize(center - eye)
    let x = normalize(cross(up, z))
    let y = cross(z, x)
    
    let X = float4(x.x, y.x, z.x, 0)
    let Y = float4(x.y, y.y, z.y, 0)
    let Z = float4(x.z, y.z, z.z, 0)
    let W = float4(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)
    
    self.init()
    columns = (X, Y, Z, W)
  }
  
  // MARK: - Orthographic matrix
  init(orthographic rect: CGRect, near: Float, far: Float) {
    let left = Float(rect.origin.x)
    let right = Float(rect.origin.x + rect.width)
    let top = Float(rect.origin.y)
    let bottom = Float(rect.origin.y - rect.height)
    let X = float4(2 / (right - left), 0, 0, 0)
    let Y = float4(0, 2 / (top - bottom), 0, 0)
    let Z = float4(0, 0, 1 / (far - near), 0)
    let W = float4(
      (left + right) / (left - right),
      (top + bottom) / (bottom - top),
      near / (near - far),
      1
    )
    self.init()
    columns = (X, Y, Z, W)
  }
  
  init(_ m: matrix_double4x4) {
    self.init()
    let matrix = float4x4(
      float4(m.columns.0),
      float4(m.columns.1),
      float4(m.columns.2),
      float4(m.columns.3)
    )
    self = matrix
  }
}

extension float3x3 {
  init(normalFrom4x4 matrix: float4x4) {
    self.init()
    columns = matrix.upperLeft.inverse.transpose.columns
  }
}

extension float4 {
  var xyz: float3 {
    get {
      float3(x, y, z)
    }
    set {
      x = newValue.x
      y = newValue.y
      z = newValue.z
    }
  }
  
  init(_ d: SIMD4<Double>) {
    self.init()
    self = [Float(d.x), Float(d.y), Float(d.z), Float(d.w)]
  }
}

extension quaternion {
  static var identity: quaternion {
    simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
  }
  // yaw(z), pitch(y), roll(x)
  init(x: Float, y: Float, z: Float) {
    self = quaternion.euler(x: x, y: y, z:z)
  }
  
  static func euler(x: Float, y: Float, z: Float) -> quaternion {
    let yaw = z
    let pitch = y
    let roll = x
    
    let cy = cos(yaw * 0.5)
    let sy = sin(yaw * 0.5)
    let cp = cos(pitch * 0.5)
    let sp = sin(pitch * 0.5)
    let cr = cos(roll * 0.5)
    let sr = sin(roll * 0.5)
    
    var q = quaternion()
    let w = cr * cp * cy + sr * sp * sy
    let x = sr * cp * cy - cr * sp * sy
    let y = cr * sp * cy + sr * cp * sy
    let z = cr * cp * sy - sr * sp * cy
    q.vector = float4(x: x, y: y, z: z, w: w)
    return q
  }
  
  var toEuler: float3 {
    var angles = float3()
    // x-axis rotation
    let sinr_cosp = 2 * (self.vector.w * self.vector.x + self.vector.y * self.vector.z)
    let cosr_cosp = 1 - 2 * (self.vector.x * self.vector.x + self.vector.y * self.vector.y)
    angles.x = atan2f(sinr_cosp, cosr_cosp)
    // y-axis rotation
    let sinp = 2 * (self.vector.w * self.vector.y - self.vector.z * self.vector.x)
    if abs(sinp) >= 1 {
      angles.y = copysignf(.pi / 2, sinp)
    } else {
      angles.y = asinf(sinp)
    }
    // z-axis rotation
    let siny_cosp = 2 * (self.vector.w * self.vector.z + self.vector.x * self.vector.y)
    let cosy_cosp = 1 - 2 * (self.vector.y * self.vector.y + self.vector.z * self.vector.z)
    angles.z = atan2f(siny_cosp, cosy_cosp)
    
    return angles
  }
  
  static func slerp(from quatA: quaternion, to quatB: quaternion, t: Float) -> quaternion {
    var qm = quaternion()
    let cosHalfTheta = quatA.vector.w * quatB.vector.w + quatA.vector.x * quatB.vector.x + quatA.vector.y * quatB.vector.y
    + quatA.vector.z * quatB.vector.z
    
    if abs(cosHalfTheta) >= 1.0 {
      qm.vector = quatA.vector
      return qm
    }
    let halfTheta = acosf(cosHalfTheta)
    let sinHalfTheta = sqrtf(1.0 - cosHalfTheta * cosHalfTheta)
    if abs(sinHalfTheta) < 0.001 {
      qm.vector.w = quatA.vector.w * 0.5 + quatB.vector.w * 0.5
      qm.vector.x = quatA.vector.x * 0.5 + quatB.vector.x * 0.5
      qm.vector.y = quatA.vector.y * 0.5 + quatB.vector.y * 0.5
      qm.vector.z = quatA.vector.z * 0.5 + quatB.vector.z * 0.5
      return qm
    }
    let ratioA = sinf((1 - t) * halfTheta) / sinHalfTheta
    let ratioB = sinf(t * halfTheta) / sinHalfTheta
    
    qm.vector.w = quatA.vector.w * ratioA + quatB.vector.w * ratioB
    qm.vector.x = quatA.vector.x * ratioA + quatB.vector.x * ratioB
    qm.vector.y = quatA.vector.y * ratioA + quatB.vector.y * ratioB
    qm.vector.z = quatA.vector.z * ratioA + quatB.vector.z * ratioB
    
    return qm
  }
}
