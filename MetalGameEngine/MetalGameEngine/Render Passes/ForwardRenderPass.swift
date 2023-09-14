import MetalKit

struct ForwardRenderPass: RenderPass {
  let label = "Forward Render Pass"
  var descriptor: MTLRenderPassDescriptor?
  
  var pipelineState: MTLRenderPipelineState
  var transparentPSO: MTLRenderPipelineState
  
  let depthStencilState: MTLDepthStencilState?
  weak var shadowTexture: MTLTexture?
  
  init(view: MTKView) {
    pipelineState = PipelineStates.createForwardPSO()
    depthStencilState = Self.buildDepthStencilState()
    transparentPSO = PipelineStates.createForwardTransparentPSO()
  }
  
  mutating func resize(view: MTKView, size: CGSize) {
  }
  
  func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params) {
    guard let descriptor,
          let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(pipelineState)
    
    renderEncoder.setFragmentBuffer(scene.lighting.lightsBuffer, offset: 0, index: LightBuffer.index)
    renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
    
    scene.skybox?.update(renderEncoder: renderEncoder)
    
    var params = params
    params.transparency = false
    for model in scene.models {
      model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
    }
    scene.terrain?.render(encoder: renderEncoder, uniforms: uniforms, params: params)
    scene.skybox?.render(renderEncoder: renderEncoder, uniforms: uniforms)
    
    renderEncoder.endEncoding()
  }
}
