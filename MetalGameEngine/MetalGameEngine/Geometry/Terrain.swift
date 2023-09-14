import Foundation
import Metal

class Terrain: Model {
  var pipelineState: MTLRenderPipelineState
  
  override init(name: String) {
    pipelineState = PipelineStates.createTerrainPSO()
    super.init(name: name)
  }
  
  override func render(encoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms, params fragment: Params) {
    encoder.setRenderPipelineState(pipelineState)
    super.render(encoder: encoder, uniforms: vertex, params: fragment)
  }
}
