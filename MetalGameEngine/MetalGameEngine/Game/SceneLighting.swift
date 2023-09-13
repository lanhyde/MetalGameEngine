import MetalKit

struct SceneLighting {
  let sunlight: Light = {
    var light = Self.buildDefaultLight()
    light.position = normalize([-1, 3, 2])
    light.color = float3(repeating: 1)
    return light
  }()
  
  var lights: [Light] = []
  var sunlights: [Light] = []
  var pointLights: [Light] = []
  var lightsBuffer: MTLBuffer?
  var sunBuffer: MTLBuffer?
  var pointBuffer: MTLBuffer?
  
  init() {
    lights = [sunlight]
    lightsBuffer = Self.createBuffer(lights: lights)
  }
  
  static func buildDefaultLight() -> Light {
    var light = Light()
    light.position = [0, 0, 0]
    light.color = float3(repeating: 1.0)
    light.specularColor = float3(repeating: 0.6)
    light.attenuation = [1, 0, 0]
    light.type = Sun
    return light
  }
  
  static func createBuffer(lights: [Light]) -> MTLBuffer {
    var lights = lights
    return Renderer.device.makeBuffer(bytes: &lights, length: MemoryLayout<Light>.stride * lights.count, options: [])!
  }
}
