import Foundation
import Metal

class Terrain: Model {
  var pipelineState: MTLRenderPipelineState
  let underwaterTexture: MTLTexture?
  
  override init(name: String) {
    pipelineState = PipelineStates.createTerrainPSO()
    underwaterTexture = try? TextureController.loadTexture(filename: "underwater-color")
    super.init(name: name)
  }
  
  override func render(encoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms, params fragment: Params) {
    encoder.setRenderPipelineState(pipelineState)
    encoder.setFragmentTexture(underwaterTexture, index: MiscTexture.index)
    super.render(encoder: encoder, uniforms: vertex, params: fragment)
  }
}
