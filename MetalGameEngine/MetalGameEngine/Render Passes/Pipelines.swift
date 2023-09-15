import MetalKit

enum PipelineStates {
  static func createPSO(descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState {
    let pipelineState: MTLRenderPipelineState
    do {
      pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
    } catch {
      fatalError(error.localizedDescription)
    }
    return pipelineState
  }
  
  static func createComputePSO(function name: String) -> MTLComputePipelineState {
    guard let kernel = Renderer.library.makeFunction(name: name)
    else { fatalError("Unable to create \(name) PSO") }
    let pipelineState: MTLComputePipelineState
    do {
      pipelineState = try Renderer.device.makeComputePipelineState(function: kernel)
    } catch {
      fatalError(error.localizedDescription)
    }
    return pipelineState
  }
  
  static func createShadowPSO() -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library?.makeFunction(name: "vertex_depth")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor = .defaultLayout
    return createPSO(descriptor: pipelineDescriptor)
  }
  
  static func createForwardPSO() -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_IBL")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor = .defaultLayout
    return createPSO(descriptor: pipelineDescriptor)
  }
  
  static func createForwardTransparentPSO() -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_PBR")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
    let attachment = pipelineDescriptor.colorAttachments[0]
    attachment?.isBlendingEnabled = true
    attachment?.rgbBlendOperation = .add
    attachment?.sourceRGBBlendFactor = .one
    attachment?.destinationRGBBlendFactor = .oneMinusSourceAlpha
    
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
    
    return createPSO(descriptor: pipelineDescriptor)
  }
  
  static func createSkyboxPSO(vertexDescriptor: MTLVertexDescriptor?) -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_skybox")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_skybox")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor = vertexDescriptor
    return createPSO(descriptor: pipelineDescriptor)
  }
  
  static func createTerrainPSO() -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_terrain")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor = .defaultLayout
    return createPSO(descriptor: pipelineDescriptor)
  }
  
  static func createWaterPSO(vertexDescriptor: MTLVertexDescriptor?) -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_water")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_water")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
    
    let attachment = pipelineDescriptor.colorAttachments[0]
    attachment?.isBlendingEnabled = true
    attachment?.rgbBlendOperation = .add
    attachment?.sourceRGBBlendFactor = .sourceAlpha
    attachment?.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor = vertexDescriptor
    return createPSO(descriptor: pipelineDescriptor)
  }
}
