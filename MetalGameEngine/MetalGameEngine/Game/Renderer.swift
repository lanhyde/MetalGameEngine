import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  static var colorPixelFormat: MTLPixelFormat!
  var options: Options
  
  var uniforms = Uniforms()
  var params = Params()
  
  init(metalView: MTKView, options: Options) {
    guard let device = MTLCreateSystemDefaultDevice(),
          let commandQueue = device.makeCommandQueue() else {
      fatalError("GPU not available")
    }
    Self.device = device
    Self.commandQueue = commandQueue
    metalView.device = device
    
    let library = device.makeDefaultLibrary()
    Self.library = library
    Self.colorPixelFormat = metalView.colorPixelFormat
    self.options = options
    
    super.init()
    
    metalView.clearColor = MTLClearColor(red: 0.93, green: 0.07, blue: 1.0, alpha: 1.0)
    metalView.depthStencilPixelFormat = .depth32Float
    mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
  }
}

extension Renderer {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    params.width = UInt32(size.width)
    params.height = UInt32(size.height)
  }
}
