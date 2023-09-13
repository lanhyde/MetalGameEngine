import MetalKit

struct Skybox {
  let mesh: MTKMesh
  var texture: MTLTexture?
  let pipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?
  
  struct SkySettings {
    var turbidity: Float = 0.28
    var sunElevation: Float = 0.6
    var upperAtmosphereScattering: Float = 0.4
    var groundAlbedo: Float = 0.8
  }
  var skySettings = SkySettings()
  
  var diffuseTexture: MTLTexture?
  var brdfLut: MTLTexture?
  
  init(textureName: String?) {
    let allocator = MTKMeshBufferAllocator(device: Renderer.device)
    let cube = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: true, geometryType: .triangles, allocator: allocator)
    do {
      mesh = try MTKMesh(mesh: cube, device: Renderer.device)
    } catch {
      fatalError("failed to create skybox mesh")
    }
    pipelineState = PipelineStates.createSkyboxPSO(vertexDescriptor: MTKMetalVertexDescriptorFromModelIO(cube.vertexDescriptor))
    depthStencilState = Self.buildDepthStencilState()
    if let textureName {
      do {
        texture = try TextureController.loadCubeTexture(imageName: textureName)
        diffuseTexture = try TextureController.loadCubeTexture(imageName: "irradiance.png")
      } catch {
        fatalError(error.localizedDescription)
      }
    } else {
      texture = loadGeneratedSkyboxTexture(dimensions: [256, 256])
    }
    brdfLut = Renderer.buildBRDF()
  }
  
  func loadGeneratedSkyboxTexture(dimensions: SIMD2<Int32>) -> MTLTexture? {
    var texture: MTLTexture?
    let skyTexture = MDLSkyCubeTexture(name: "sky", channelEncoding: .float16, textureDimensions: dimensions, turbidity: skySettings.turbidity, sunElevation: skySettings.sunElevation, upperAtmosphereScattering: skySettings.upperAtmosphereScattering, groundAlbedo: skySettings.groundAlbedo)
    do {
      let textureLoader = MTKTextureLoader(device: Renderer.device)
      texture = try textureLoader.newTexture(texture: skyTexture, options: nil)
    } catch {
      print(error.localizedDescription)
    }
    return texture
  }
  
  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .lessEqual
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }
  
  func update(renderEncoder: MTLRenderCommandEncoder) {
    renderEncoder.setFragmentTexture(texture, index: SkyboxTexture.index)
    renderEncoder.setFragmentTexture(diffuseTexture, index: SkyboxDiffuseTexture.index)
    renderEncoder.setFragmentTexture(brdfLut, index: BRDFLutTexture.index)
  }
  
  func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
    renderEncoder.pushDebugGroup("Skybox")
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
    
    var uniforms = uniforms
    uniforms.viewMatrix.columns.3 = [0, 0, 0, 1]
    renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
    let submesh = mesh.submeshes[0]
    
    renderEncoder.setFragmentTexture(texture, index: SkyboxTexture.index)
    renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: 0)
    renderEncoder.popDebugGroup()
  }
}
