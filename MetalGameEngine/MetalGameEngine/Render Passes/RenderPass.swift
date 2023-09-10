import MetalKit

protocol RenderPass {
  var label: String { get }
  var descriptor: MTLRenderPassDescriptor? { get set }
  mutating func resize(view: MTKView, size: CGSize)
  func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params)
}

extension RenderPass {
  static func buildDepthStentilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }
}
