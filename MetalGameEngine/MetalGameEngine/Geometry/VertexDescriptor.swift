import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor? {
    MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
  }
}

extension MDLVertexDescriptor {
  static var defaultLayout: MDLVertexDescriptor = {
    let vertexDescriptor = MDLVertexDescriptor()
    
    var offset = 0
    vertexDescriptor.attributes[Position.index] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: VertexBuffer.index)
    offset += MemoryLayout<float3>.stride
    vertexDescriptor.attributes[Normal.index] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: offset, bufferIndex: VertexBuffer.index)
    offset += MemoryLayout<float3>.stride
    vertexDescriptor.layouts[VertexBuffer.index] = MDLVertexBufferLayout(stride: offset)
    // UVs
    vertexDescriptor.attributes[UV.index] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 0, bufferIndex: UVBuffer.index)
    vertexDescriptor.layouts[UVBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float2>.stride)
    // Vertex Color
    vertexDescriptor.attributes[Color.index] = MDLVertexAttribute(name: MDLVertexAttributeColor, format: .float3, offset: 0, bufferIndex: ColorBuffer.index)
    vertexDescriptor.layouts[ColorBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
    // Tangent
    vertexDescriptor.attributes[Tangent.index] = MDLVertexAttribute(name: MDLVertexAttributeTangent, format: .float3, offset: 0, bufferIndex: TangentBuffer.index)
    vertexDescriptor.layouts[TangentBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
    // Bitangent
    vertexDescriptor.attributes[Bitangent.index] = MDLVertexAttribute(name: MDLVertexAttributeBitangent, format: .float3, offset: 0, bufferIndex: BitangentBuffer.index)
    vertexDescriptor.layouts[Bitangent.index] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
    
    return vertexDescriptor
  }()
}

extension Attributes {
  var index: Int {
    Int(rawValue)
  }
}

extension BufferIndices {
  var index: Int {
    Int(rawValue)
  }
}

extension TextureIndices {
  var index: Int {
    Int(rawValue)
  }
}

extension RenderTarget {
  var index: Int {
    Int(rawValue)
  }
}
