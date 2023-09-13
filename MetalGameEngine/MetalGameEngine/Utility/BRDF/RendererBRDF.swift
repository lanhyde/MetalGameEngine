import MetalKit

extension Renderer {
  static func buildBRDF() -> MTLTexture? {
    let size = 256
    let brdfPipelineState = PipelineStates.createComputePSO(function: "integrateBRDF")
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
          let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return nil }
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rg16Float, width: size, height: size, mipmapped: false)
    descriptor.usage = [.shaderRead, .shaderWrite]
    let lut = Self.device.makeTexture(descriptor: descriptor)
    computeEncoder.setComputePipelineState(brdfPipelineState)
    computeEncoder.setTexture(lut, index: 0)
    let threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
    let threadgroups = MTLSize(width: size / threadsPerThreadgroup.width, height: size / threadsPerThreadgroup.height, depth: 1)
    computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
    computeEncoder.endEncoding()
    commandBuffer.commit()
    return lut
  }
}
